require 'jrubyfx'
require_relative 'ast_tree_view_builder'

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
  
  property_accessor :ruby_code
  
  def initialize
    @ruby_code = SimpleStringProperty.new("")
    @ast_root_node = JRuby.parse(@ruby_code.get)
    fill_ast_view
    # bind change of Ruby code to reparsing an AST
    ruby_code_property.add_change_listener do |new_code|
      @ast_root_node = JRuby.parse(new_code)
      fill_ast_view
    end
    # bind ruby view to value of ruby_code
    @ruby_view.text_property.bind(ruby_code_property)
  end
  
  def fill_ast_view
    # clear view
    @ast_view.root = nil
    # refill it
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(@ast_root_node)
  end
  
end