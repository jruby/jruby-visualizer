require 'jrubyfx'

class CompilerData
  include JRubyFX
  
  @@ir_builder = nil
  
  attr_accessor :ast_root, :ir_scope
  property_accessor :ruby_code
  
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
    @ast_root = reparse(@ruby_code)
    @ir_scope = build_ir(@ast_root)
    # bind change of Ruby code to reparsing an AST and building IR
    ruby_code_property.add_change_listener do |new_code|
      @ast_root = reparse(new_code)
      @ir_scope = build_ir(@ast_root)
    end
  end

end
