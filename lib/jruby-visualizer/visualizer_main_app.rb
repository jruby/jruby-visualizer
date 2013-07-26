require 'jrubyfx'

fxml_root File.join(File.dirname(__FILE__), "ui")

class VisualizerMainApp < JRubyFX::Application
  def start(stage)
    with(stage, title: "JRuby Visualizer") do
      fxml JRubyVisualizerController
      show
    end
  end
end

class JRubyVisualizerController
  include JRubyFX::Controller
  fxml "jruby-visualizer.fxml"
end