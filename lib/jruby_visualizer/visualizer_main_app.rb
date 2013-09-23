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
require_relative 'ast_tree_view_builder'
require_relative 'compiler_data'
require_relative 'ir_visualizer'
require_relative 'cfg_visualizer'
require_relative 'jruby_visualizer'
require_relative 'about_page'

resource_root :images, File.join(File.dirname(__FILE__), 'ui', 'img'), 'ui/img'
fxml_root File.join(File.dirname(__FILE__), 'ui')

#
# A ListCell that enables to delete the cell by a right click (ContextMenu)
#
class DeletableListCell < Java::javafx.scene.control.ListCell
  include JRubyFX
  
  attr_reader :delete_menu
  
  def initialize
    delete_info_item = MenuItem.new('Delete Information')
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

#
# A concurrent Task for a JRubyFX application from the Visualizer
#
class SubAppTask < Java::javafx.concurrent.Task

  def initialize(view_name)
    super()
    # (select view)
    case view_name
    when :ir_view
      @view = IRVisualizer.new
    when :cfg_view
      @view = CFGVisualizer.new
    when :about_page
      @view = AboutPage.new
    else
      raise "unknown name for a view: #{view_name}"
    end
  end

  def call
    stage = Java::javafx.stage.Stage.new
    @view.start(stage)
  end
end

#
# The UI for the whole JRuby visualizer:
#  * shows AST and Ruby code
#  * enables traceability between AST nodes and Ruby code lines (clicks on AST)
#  * launches other UI applications
#  * can execute compiler passes
#
class VisualizerMainApp < JRubyFX::Application

  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: 'JRuby Visualizer') do
      fxml(JRubyVisualizerController, initialize: [compiler_data])
      icons.add(Image.new(resource_url(:images, 'jruby-icon-32.png').to_s))
      show
    end
  end
end

#
# Usual controller functionality:
#  * loading fxml file
#  * forward UI actions to the CompilerData container
#  * launch other Applications as concurrent tasks
#
class JRubyVisualizerController
  include JRubyFX::Controller
  fxml 'jruby-visualizer.fxml'

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

    # enable scrolling to the ruby code on clicks within the AST
    scroll_ruby_to_selected_ast

    # display the IR compiler passes and set the selection to first pass
    @ir_passes_names = CompilerData.compiler_passes_names
    @ir_passes_box.items = FXCollections.observable_array_list(@ir_passes_names)
    @ir_passes_box.value = @selected_ir_pass = @ir_passes_names[0]

    # background tasks for other views
    @ir_view_task = SubAppTask.new(:ir_view)
    @cfg_view_task = SubAppTask.new(:cfg_view)
    @about_task = SubAppTask.new(:about_page)

    # Use ListCell with Delete Context Menu in the view for compile information
    @compile_information.cell_factory = proc { DeletableListCell.new }
    # information property back ended by the list view for compile information
    @information = @compile_information.items
  end

  def select_ir_pass
    @selected_ir_pass = @ir_passes_box.value
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

  def clear_information_view
    @information.clear
  end

  def reset_passes
    @compiler_data.reset_scheduler
    @selected_ir_pass = @ir_passes_names[0]
    @ir_passes_box.value = @selected_ir_pass
    clear_information_view
  end

  def fill_ast_view(root_node)
    # clear view
    @ast_view.root = nil
    # refill it
    tree_builder = ASTTreeViewBuilder.new(@ast_view)
    tree_builder.build_view(root_node)
  end

  def self.pixel_height_of_line
    monospaced = Java::javafx.scene.text.FontBuilder::create.name('monospaced').size(13).build
    text = Text.new('  JRubyVisualizer.visualize(ruby_code)')
    text.set_font(monospaced)
    text.get_layout_bounds.get_height
  end

  def mark_selected_line(line_number)
    ruby_code = @ruby_view.text
    ruby_lines = ruby_code.lines.to_a
    char_begin = ruby_lines[0...line_number].join.chars.count
    @ruby_view.position_caret(char_begin)
    char_end = ruby_lines[line_number].chars.count + char_begin
    @ruby_view.extend_selection(char_end)
  end

  def scroll_ruby_to_selected_ast
    @ast_view.selection_model.selected_item_property.add_change_listener do |ast_tree_cell|
      start_line = ast_tree_cell.node.position.start_line
      # first mark the line then scroll to it
      mark_selected_line(start_line)
      line_pixels = self.class.pixel_height_of_line
      # calculate the actual height of the current line in pixels
      scroll_to_pixels = line_pixels * start_line
      # scroll to start position of current ast tree cell
      @ruby_view.set_scroll_top(scroll_to_pixels)
    end
    @ast_view.selection_model.set_selected_item(@ast_view.root)
  end

  def close_app
    Platform.exit
  end

  def launch_ir_view
    worker_state = Java::javafx.concurrent.Worker::State
    state = @ir_view_task.state
    if state == worker_state::READY
      Platform.run_later(@ir_view_task)
    elsif state != worker_state::RUNNING
      @ir_view_task = SubAppTask.new(:ir_view)
      Platform.run_later(@ir_view_task)
    end
  end

  def launch_cfg_view
    worker_state = Java::javafx.concurrent.Worker::State
    state = @cfg_view_task.state
    if state == worker_state::READY
      Platform.run_later(@cfg_view_task)
    elsif state != worker_state::RUNNING
      @cfg_view_task = SubAppTask.new(:cfg_view)
      Platform.run_later(@cfg_view_task)
    end
  end

  def launch_about
    worker_state = Java::javafx.concurrent.Worker::State
    state = @about_task.state
    if state == worker_state::READY
      Platform.run_later(@about_task)
    elsif state != worker_state::RUNNING
      @about_task = SubAppTask.new(:about_page)
      Platform.run_later(@about_task)
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  JRubyVisualizer.compiler_data = CompilerData.new(
    "class Foo\n  def bar\n    42\n  end\nend\nFoo.new.bar\n")
  VisualizerMainApp.launch
end
