require 'java'
require 'jruby'
require_relative 'visualizer_compiler_pass_listener'
require_relative 'visualizer_main_app'

module JRubyVisualizer
  @@main_app = nil
  
  def self.launched?
    !!@@main_app
  end
  
  def self.launch(ruby_code)
    if launched?
      return
    end
    VisualizerMainApp.launch(ruby_code)
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
  
  def self.visualize(ruby_code)
    return unless pass_listener?
    
    # launch App with Ruby code as input
    launch(ruby_code)
    
    #builder = set_up_ir_builder
    #scope = builder.build_root(root_node)
 
    # TODO IR stepping with scheduler as javafx tasks
    #run_ir_passes(scope)
    # TODO visualize AST and scope
  end
 
end

if __FILE__ == $0
  vis = JRubyVisualizer
  vis.inject_pass_listener unless vis.pass_listener?
  vis.visualize("def foo; 42; end; foo")
end
