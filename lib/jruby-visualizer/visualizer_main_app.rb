require 'jrubyfx'
require_relative 'ast_tree_view_builder'

fxml_root File.join(File.dirname(__FILE__), "ui")

class VisualizerMainApp < JRubyFX::Application
  
  def start(stage)
    with(stage, title: "JRuby Visualizer") do
      fxml JRubyVisualizerController
      fill_ast_view(stage)
      show
    end
  end
end

class JRubyVisualizerController
  include JRubyFX::Controller
  fxml "jruby-visualizer.fxml"
  
  def fill_ast_view
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(@root_node)
  end
  
  
  def initialize(root_node)
    @ast_root_node = root_node
    puts @ast_root_node
    puts @ast_view.class
    # TODO fill ast_view
  end
  
end