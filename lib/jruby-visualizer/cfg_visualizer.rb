require 'jrubyfx'
require_relative 'jruby_visualizer'

fxml_root File.join(File.dirname(__FILE__), "ui")

class CFGVisualizer < JRubyFX::Application
  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: "Visualization of Control Flow Graphs (CFG)") do
      fxml(CFGVisualizerController, initialize: [compiler_data])
      show
    end
  end
end

class CFGVisualizerController
  include JRubyFX::Controller
  fxml "cfg-view.fxml"
  
  attr_accessor :compiler_data
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
  end
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "a = 1 + 4 + 7;\nc = nil;\nj = 1;\ni = 3 + j;\nputs i")
  CFGVisualizer.launch
end