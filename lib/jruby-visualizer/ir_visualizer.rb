require 'jrubyfx'
require_relative 'ir_pretty_printer'
require_relative 'jruby_visualizer'

fxml_root File.join(File.dirname(__FILE__), "ui")

class IRVisualizer < JRubyFX::Application
  
  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: "Intermediate Representation (IR) Visualizer") do
      fxml(IRVisualizerController, initialize: [compiler_data])
      show
    end
  end
end

class IRVisualizerController
  include JRubyFX::Controller
  fxml "ir-view.fxml"
  
  attr_accessor :compiler_data
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
    pretty_ir_string = IRPrettyPrinter.pretty_string(@compiler_data.ir_scope)
    @ir_view.text = pretty_ir_string
    @compiler_data.ir_scope_property.add_change_listener do |new_scope|
      pretty_ir_string = IRPrettyPrinter.pretty_string(new_scope)
      @ir_view.text = pretty_ir_string
    end
  end
  
  def step_ir_pass
    @compiler_data.step_ir_passes
  end
  
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "a = 1 + 4 + 7;\nc = nil;\nj = 1;\ni = 3 + j;\nputs i")
  IRVisualizer.launch
end