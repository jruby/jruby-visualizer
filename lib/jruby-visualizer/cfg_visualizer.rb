require 'jrubyfx'

fxml_root File.join(File.dirname(__FILE__), "ui")

class CFGVisualizer < JRubyFX::Application
  def start(stage)
    with(stage, title: "Visualization of Control Flow Graphs (CFG)") do
      fxml CFGVisualizerController
      show
    end
  end
end

class CFGVisualizerController
  include JRubyFX::Controller
  fxml "cfg-view.fxml"
end