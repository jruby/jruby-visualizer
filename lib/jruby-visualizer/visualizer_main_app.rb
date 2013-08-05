require 'jrubyfx'
require_relative 'ast_tree_view_builder'

fxml_root File.join(File.dirname(__FILE__), "ui")

class VisualizerMainApp < JRubyFX::Application
  
  def fill_ast_view(stage, root_node)
    tree_view = stage['#ast_view']
    tree_builder = ASTTreeViewBuilder.new(tree_view)
    tree_builder.build_view(root_node)
  end
  
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