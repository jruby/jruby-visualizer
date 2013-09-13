require 'jrubyfx'

resource_root :images, File.join(File.dirname(__FILE__), "ui", "img"), "ui/img"
fxml_root File.join(File.dirname(__FILE__), "ui")

class AboutPage < JRubyFX::Application
  def start(stage)
    with(stage, title: "About the JRuby Visualizer") do
      fxml(AboutPageController)
      icons.add(Image.new(resource_url(:images, "jruby-icon-32.png").to_s))
      show
    end
  end
  
end

class AboutPageController
  include JRubyFX::Controller
  fxml "about.fxml"
  
end

if __FILE__ == $0
  AboutPage.launch
end