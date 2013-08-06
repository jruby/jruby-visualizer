require 'jrubyfx'
require_relative 'ir_pretty_printer'

fxml_root File.join(File.dirname(__FILE__), "ui")

class IRVisualizer < JRubyFX::Application
  
  def init
    # TODO read compiler data from main app
    @compiler_data = nil
  end
  
  def start(stage)
    with(stage, title: "Intermediate Representation (IR) Visualizer") do
      fxml(IRVisualizerController, initialize: [@compiler_data])
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
    @compiler_data.ir_scope_property.add_change_listener do |new_scope|
      pretty_ir_string = IRPrettyPrinter.print_ir(new_scope)
      puts pretty_ir_string
      @ir_view.text = pretty_ir_string
    end
  end
end