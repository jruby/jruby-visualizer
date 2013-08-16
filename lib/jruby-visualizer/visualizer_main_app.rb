require 'jrubyfx'
require_relative 'ast_tree_view_builder'
require_relative 'compiler_data'
require_relative 'ir_visualizer'
require_relative 'cfg_visualizer'
require_relative 'jruby_visualizer'

fxml_root File.join(File.dirname(__FILE__), "ui")

class DeletableListCell < Java::javafx.scene.control.ListCell
  include JRubyFX
  
  attr_reader :delete_menu
  
  def initialize
    delete_info_item = MenuItem.new("Delete Information")
    @delete_menu = ContextMenu.new(delete_info_item)
    delete_info_item.on_action do
      items = list_view.items
      info_string = get_string
      if items.include?(info_string)
        items.remove_all(info_string)
      end
    end
  end
  
  def updateItem(item, empty)
    super(item, empty)
    
    if empty
      set_text(nil)
      set_graphic(nil)
    else
      set_text(get_string)
      set_graphic(nil)
      set_context_menu(@delete_menu)
    end
    
  end
  
  private
  def get_string
    if item
      item.to_s
    else
      ''
    end
  end
  
end

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
    @view.start(stage)
  end
end

class VisualizerMainApp < JRubyFX::Application
  
  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: "JRuby Visualizer") do
      fxml(JRubyVisualizerController, initialize: [compiler_data])
      show
    end
  end
end

class JRubyVisualizerController
  include JRubyFX::Controller
  fxml "jruby-visualizer.fxml"
  
  attr_accessor :compiler_data, :information
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
    fill_ast_view(@compiler_data.ast_root)
    # bind change of ast to redrawing AST
    @compiler_data.ast_root_property.add_change_listener do |new_ast|
      fill_ast_view(new_ast)
    end
    # bind ruby view to value of ruby_code
    @ruby_view.text_property.bind(@compiler_data.ruby_code_property)
    
    # display the IR compiler passes and set the selection to first pass
    @ir_passes_names = CompilerData.compiler_passes_names
    @ir_passes_box.items = FXCollections.observable_array_list(@ir_passes_names)
    @ir_passes_box.value = @selected_ir_pass = @ir_passes_names[0]
    
    # background tasks for other views
    @ir_view_task = nil
    @cfg_view_task = nil
    
    # Use ListCell with Delete Context Menu in the view for compile information
    @compile_information.cell_factory = proc { DeletableListCell.new }
    # information property back ended by the list view for compile information
    @information = @compile_information.items
  end
  
  def select_ir_pass
    @selected_ir_pass = @ir_passes_box.value
    puts "selected ir pass #{@selected_ir_pass}"
  end
  
  def run_previous_passes_for_selection
    if @compiler_data.current_pass.nil?
      return # beginning of ir passes
    end
    current_pass_name = CompilerData.pass_to_s(@compiler_data.current_pass)
    select_pass_index = @ir_passes_names.index(@selected_ir_pass)
    current_pass_index = @ir_passes_names.index(current_pass_name)
    if select_pass_index == current_pass_index
      return
    elsif current_pass_index < select_pass_index
      @compiler_data.step_ir_passes
      run_previous_passes_for_selection
    else
      reset_passes
      run_previous_passes_for_selection
    end
  end
  
  def step_ir_pass
    if @compiler_data.next_pass
      run_previous_passes_for_selection
      @compiler_data.step_ir_passes
      @selected_ir_pass = CompilerData.pass_to_s(@compiler_data.current_pass)
      @ir_passes_box.value = @selected_ir_pass
      @information << "Successfully passed #{@selected_ir_pass}"
    end
  end
  
  def reset_passes
    @compiler_data.reset_scheduler
    @selected_ir_pass = @ir_passes_names[0]
    @ir_passes_box.value = @selected_ir_pass
  end
  
  def fill_ast_view(root_node)
    # clear view
    @ast_view.root = nil
    # refill it
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(root_node)
  end
  
  def close_app
    Platform.exit
  end
  
  def launch_ir_view
    if @ir_view_task.nil?
      @ir_view_task = SubAppTask.new(:ir_view)
      Platform.run_later(@ir_view_task)
    end
  end
  
  def launch_cfg_view
    if @cfg_view_task.nil?
      @cfg_view_task = SubAppTask.new(:cfg_view)
      Platform.run_later(@cfg_view_task)
    end
  end
  
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "class Foo\n  def bar\n    42\n  end\nend\nFoo.new.bar\n")
  VisualizerMainApp.launch
end
