=begin
JRuby Visualizer
Copyright (C) 2013 The JRuby Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'jrubyfx'

resource_root :images, File.join(File.dirname(__FILE__), 'ui', 'img'), 'ui/img'
fxml_root File.join(File.dirname(__FILE__), 'ui')

#
# JRubyFX Application showing information about the Visualizer
#
class AboutPage < JRubyFX::Application

  def start(stage)
    with(stage, title: 'About the JRuby Visualizer') do
      fxml(AboutPageController)
      icons.add(Image.new(resource_url(:images, 'jruby-icon-32.png').to_s))
    end
  
    stage['#jruby_logo'].set_on_mouse_clicked do |e|
        open_browser_with('http://jruby.org')
    end
    stage['#jruby_hyperlink'].set_on_action do |e|
        open_browser_with('http://jruby.org')
    end
    stage['#visualizer_hyperlink'].set_on_action do |e|
      open_browser_with('https://github.com/jruby/jruby-visualizer')
    end
    stage.show
  end

  def open_browser_with(url)
    get_host_services.show_document(url)
  end

end

#
# Controller loads the fxml file for the About Page
#
class AboutPageController
  include JRubyFX::Controller
  fxml 'about.fxml'

end

if __FILE__ == $PROGRAM_NAME
  AboutPage.launch
end

