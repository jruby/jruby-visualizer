require 'java'
require 'jruby'
require_relative 'visualizer_compiler_pass_listener'
require_relative 'visualizer_main_app'

module JRubyVisualizer
  @@main_app = nil
  
  def launched?
    !!@@main_app
  end
  
  def launch
    VisualizerMainApp.launch
    @@main_app = VisualizerMainApp
  end
  
  def self.inject_pass_listener
    # create and add listener
    vis_pass_listener = VisualizerCompilerPassListener.new
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.add_listener(vis_pass_listener)

    # activate visualization listener
    JRuby::IR.visualize = true
  end
  
  def self.pass_listener?
    JRuby::IR.visualize
  end
  
  def self.run_ir_passes(scope)
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.get_compiler_passes(scope).each do |pass|
      pass.run(scope)
    end
  end
  
  def self.visualize(ruby_code)
    return unless pass_listener?
    # TODO start GUI
    launch
    
    # parse ruby_code into AST
    root_node = JRuby.parse(ruby_code)
    
    builder = set_up_ir_builder
    scope = builder.build_root(root_node)
 
    run_ir_passes(scope)
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
  vis.inject_pass_listener unless vis.pass_listener?
  vis.visualize("def foo; 42; end; foo")
end
