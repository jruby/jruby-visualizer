require 'java'
require 'jruby'
require_relative 'visualizer_compiler_pass_listener'

module JRubyVisualizer
  def self.inject_pass_listener
    # create and add listener
    vis_pass_listener = VisualizerCompilerPassListener.new
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.add_listener(vis_pass_listener)

    # activate visualization listener
    JRuby::IR.visualize = true
  end
  
  def self.has_pass_listener
    JRuby::IR.visualize
  end
  
  def self.visualize(ruby_code)
    return unless has_pass_listener
    # TODO start GUI
    
    # parse ruby_code into AST
    root_node = JRuby.parse(ruby_code)
    
    builder = set_up_ir_builder
    scope = builder.build_root(root_node)
    
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.get_compiler_passes(scope).each do |pass|
      pass.run(scope)
    end
    
    # TODO visualize AST and scope
  end
  
  def self.set_up_ir_builder
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.dry_run = true

    builder = 
      if JRuby::runtime.is1_9?
      org.jruby.ir.IRBuilder19
    else
      org.jruby.ir.IRBuilder
    end
    builder = builder.new(ir_manager)
  end
end

if __FILE__ == $0
  vis = JRubyVisualizer
  vis.inject_pass_listener unless vis.has_pass_listener
  vis.visualize("def foo; 42; end; foo")
end
