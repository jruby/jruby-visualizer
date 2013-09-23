=begin
JRuby Visualizer
Copyright (C) 2013 The JRuby Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'jrubyfx'

#
# JavaFX Property that fires always when the set method is called
#
class FireChangeObjectProperty < Java::javafx.beans.property.SimpleObjectProperty
  def initialize(*args)
    raise ArgumentError.new "wrong number of arguments (#{args.length} for 3)" if args.length > 3
    super
  end

  def set(new_val)
    super(new_val)
    fire_value_changed_event
  end
end

#
# Data container for
#  * Abstract Syntax Tree (AST),
#  * Intermediate Code (IR)
#  * Ruby Code
# It models and handles the dependencies between those compiler artifacts with
# JRubyFX properties
#
class CompilerData
  include JRubyFX

  @@ir_builder = nil

  property_accessor :ruby_code, :ast_root, :ir_scope
  attr_accessor :current_pass, :next_pass

  def self.parse(code)
    JRuby.parse(code)
  end
  
  def self.create_ir_builder
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.dry_run = true

    org.jruby.ir.IRBuilder::createIRBuilder(JRuby::runtime, ir_manager)
  end

  def self.build_ir(root_node)
    unless @@ir_builder
      @@ir_builder = create_ir_builder
    end
    @@ir_builder.build_root(root_node)
  end

  def self.pass_to_s(pass)
    pass.class.to_s.split("::").last
  end

  def self.compiler_passes_names
    scheduler = JRuby::runtime.ir_manager.schedule_passes
    scheduler.map do |pass|
      pass_to_s(pass)
    end
  end

  def reset_scheduler
    ir_manager = JRuby::runtime.ir_manager
    @scheduler = ir_manager.schedule_passes.iterator
    if @scheduler.has_next
      @current_pass = nil
      @next_pass = @scheduler.next
    else
      @current_pass = @next_pass = nil
    end
    # trigger to re build the old ir scope
    @ir_scope.set(self.class.build_ir(@ast_root.get))
  end

  def initialize(ruby_code='')
    @ruby_code = SimpleStringProperty.new(ruby_code)
    @ast_root = SimpleObjectProperty.new(self, 'ast_root', self.class.parse(ruby_code))
    @ir_scope = FireChangeObjectProperty.new(self, 'ir_scope', self.class.build_ir(@ast_root.get))
    # bind change of Ruby code to reparsing an AST and set the property
    @ruby_code.add_invalidation_listener do |new_code_property|
      @ast_root.set(self.class.parse(new_code_property.get))
    end
    # bind change of AST to rebuilding IR and set the property
    @ast_root.add_invalidation_listener do |new_ast_property|
      @ir_scope.set(self.class.build_ir(new_ast_property.get))
    end

    # initialize scheduler
    reset_scheduler
  end

  def self.run_pass_on_all_scopes(pass, scope)
    pass.run(scope)
    scope.lexical_scopes.each do |lex_scope|
      run_pass_on_all_scopes(pass, lex_scope)
    end
  end

  def step_ir_passes
    if @next_pass
      @current_pass = @next_pass
      @next_pass =
        if @scheduler.has_next
          @scheduler.next
        else
          nil
        end
      scope = @ir_scope.get
      self.class.run_pass_on_all_scopes(@current_pass, scope)
      @ir_scope.set(scope)
    end
  end

end

