require 'jrubyfx'
require_relative 'ast_tree_view_builder'
require_relative 'compiler_data'

fxml_root File.join(File.dirname(__FILE__), "ui")

class VisualizerMainApp < JRubyFX::Application
  
  def init
    params = parameters.raw
    ruby_code = params[0]
    @compiler_data = CompilerData.new(ruby_code)
  end
  
  def start(stage)
    compiler_data = @compiler_data
    with(stage, title: "JRuby Visualizer") do
      fxml(JRubyVisualizerController, initialize: [compiler_data])
      show
    end
  end
end

class JRubyVisualizerController
  include JRubyFX::Controller
  fxml "jruby-visualizer.fxml"
  
  attr_accessor :compiler_data
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
    #puts "This should be the ruby code: |#{ruby_code}|"
    #@ruby_code = SimpleStringProperty.new(ruby_code)
    #@ast_root_node = JRuby.parse(@ruby_code.get)
    fill_ast_view(@compiler_data.ast_root)
    # bind change of ast to redrawing AST
    @compiler_data.ast_root_property.add_change_listener do |new_ast|
      fill_ast_view(new_ast)
    end
    # bind ruby view to value of ruby_code
    @ruby_view.text_property.bind(@compiler_data.ruby_code_property)
    puts @compiler_data.ir_scope.instrs.to_s
  end
  
  def fill_ast_view(root_node)
    # clear view
    @ast_view.root = nil
    # refill it
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(root_node)
  end
  
end