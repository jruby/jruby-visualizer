require 'jrubyfx'

class CompilerData
  include JRubyFX
  
  @@ir_builder = nil
  
  property_accessor :ruby_code, :ast_root, :ir_scope
  
  def self.parse(code)
    JRuby.parse(code)
  end
  
  def self.create_ir_builder
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.dry_run = true

    builder = 
      if JRuby::runtime.is1_9?
      org.jruby.ir.IRBuilder19
    else
      org.jruby.ir.IRBuilder
    end
    builder.new(ir_manager)
  end
  
  def self.build_ir(root_node)
    unless @@ir_builder
      @@ir_builder = create_ir_builder
    end
    @@ir_builder.build_root(root_node)
  end
  
  def initialize(ruby_code='')
    @ruby_code = SimpleStringProperty.new(ruby_code)
    @ast_root = SimpleObjectProperty.new(self, "ast_root", self.class.parse(ruby_code))
    @ir_scope = SimpleObjectProperty.new(self, "ir_scope", self.class.build_ir(@ast_root.get))
    # bind change of Ruby code to reparsing an AST and set the property
    ruby_code_property.add_change_listener do |new_code|
      @ast_root = self.class.parse(new_code)
    end
    # bind change of AST to rebuilding IR and set the property
    ast_root_property.add_change_listener do |new_ast|
      @ir_scope = self.class.build_ir(new_ast)
    end
  end

end
