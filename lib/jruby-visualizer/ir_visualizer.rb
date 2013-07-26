require 'jrubyfx'

fxml_root File.join(File.dirname(__FILE__), "ui")

class IRVisualizer < JRubyFX::Application
  def start(stage)
    with(stage, title: "Intermediate Representation (IR) Visualizer") do
      fxml IRVisualizerController
      show
    end
  end
end

class IRVisualizerController
  include JRubyFX::Controller
  fxml "ir-view.fxml"
end