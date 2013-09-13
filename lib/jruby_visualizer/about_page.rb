require 'jrubyfx'

resource_root :images, File.join(File.dirname(__FILE__), "ui", "img"), "ui/img"
fxml_root File.join(File.dirname(__FILE__), "ui")

class AboutPage < JRubyFX::Application
  
  def start(stage)
    with(stage, title: "About the JRuby Visualizer") do
      fxml(AboutPageController)
      icons.add(Image.new(resource_url(:images, "jruby-icon-32.png").to_s))
    end
    
    stage['#jruby_logo'].set_on_mouse_clicked do |e|
        open_browser_with("http://jruby.org")
      end
    stage['#jruby_hyperlink'].set_on_action do |e|
        open_browser_with("http://jruby.org")
      end
    stage['#visualizer_hyperlink'].set_on_action do |e|
      open_browser_with("https://github.com/jruby/jruby-visualizer")
    end
    stage.show
  end
  
  def open_browser_with(url)
    get_host_services.show_document(url)
  end
  
end

class AboutPageController
  include JRubyFX::Controller
  fxml "about.fxml"
  
end

if __FILE__ == $0
  AboutPage.launch
end