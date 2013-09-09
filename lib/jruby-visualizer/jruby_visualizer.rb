require 'java'
require 'jruby'
require_relative 'visualizer_compiler_pass_listener'
require_relative 'visualizer_main_app'

module JRubyVisualizer
  @@main_app = nil
  @@compiler_data = nil
  
  def self.compiler_data
    @@compiler_data
  end
  
  def self.compiler_data=(new_data)
    @@compiler_data = new_data
  end
  
  def self.launched?
    !!@@main_app
  end
  
  def self.launch
    if launched?
      return
    end
    unless @@compiler_data
      raise "Cannot launch Visualizer without a ComiplerData object"
    end
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
  
  def self.visualize(ruby_code)
    unless pass_listener?
      inject_pass_listener
    end
    @@compiler_data = CompilerData.new(ruby_code)
    # launch App with Ruby code as input
    launch
  end
 
end

if __FILE__ == $0
  vis = JRubyVisualizer
  vis.visualize("def foo; 42; end; foo")
end
