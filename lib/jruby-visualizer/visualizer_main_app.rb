require 'jrubyfx'
require_relative 'ast_tree_view_builder'
require_relative 'compiler_data'
require_relative 'ir_visualizer'
require_relative 'cfg_visualizer'

fxml_root File.join(File.dirname(__FILE__), "ui")

class SubAppTask < Java::javafx.concurrent.Task
  
  def initialize(view_name)
    super()
    # (select view)
    case view_name
    when :ir_view
      @view = IRVisualizer.new
    when :cfg_view
      @view = CFGVisualizer.new
    else
      raise "unknown name for a view: #{view_name}"
    end
  end
  
  def call
    stage = Java::javafx.stage.Stage.new
    puts stage
    @view.start(stage)
    puts "done"
  end
end

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
    fill_ast_view(@compiler_data.ast_root)
    # bind change of ast to redrawing AST
    @compiler_data.ast_root_property.add_change_listener do |new_ast|
      fill_ast_view(new_ast)
    end
    # bind ruby view to value of ruby_code
    @ruby_view.text_property.bind(@compiler_data.ruby_code_property)
    
    # background tasks for other views
    @ir_view_task = nil
    @cfg_view_task = nil
    puts @compiler_data.ir_scope.instrs.to_s
  end
  
  def fill_ast_view(root_node)
    # clear view
    @ast_view.root = nil
    # refill it
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(root_node)
  end
  
  def close_app
    # TODO close other views
    Platform.exit
  end
  
  def launch_ir_view
    # TODO launch ir view as a background task
    # pass CompilerData
    puts "launched ir_view"
    if @ir_view_task.nil?
      @ir_view_task = SubAppTask.new(:ir_view)
      Platform.run_later(@ir_view_task)
    end
  end
  
  def launch_cfg_view
    # TODO launch cfg_view as a background task
    # pass CompilerData
    puts "launched cfg_view"
    if @cfg_view_task.nil?
      @cfg_view_task = SubAppTask.new(:cfg_view)
      Platform.run_later(@cfg_view_task)
    end
  end
  
end