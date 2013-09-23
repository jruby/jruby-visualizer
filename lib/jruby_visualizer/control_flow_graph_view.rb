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

#
# A custom JRubyFX control for a basic block of a CFG. This view is a composite
# with a TextArea for the basic blocks and live links to basic blocks that
# can succeed after this one
#
class BasicBlockBox < Java::javafx.scene.layout.VBox
  include JRubyFX

  attr_reader :basic_block, :instrs_box, :successors, :successor_buttons

  def initialize(basic_block, cfg, cfg_list_view)
    super(5)
    @basic_block = basic_block
    instructions = instrs
    @instrs_box = TextArea.new(instructions)
    line_no = instructions.lines.count
    @instrs_box.set_pref_row_count(line_no)
    @instrs_box.set_style('-fx-font-family: monospaced')
    @instrs_box.set_editable(false)
    @successors = cfg.get_outgoing_destinations(@basic_block).to_a
    if @successors.empty?
      get_children << @instrs_box
    else
      @successor_buttons = @successors.map do |bb|
        button = Button.new(bb.to_s)
        button.set_on_action do
          # TODO rewrite this ugly code
          i = button.get_text.scan(/.*\[(\d+):.*\]/)[0][0]
          index = i.to_i - 1
          cfg_list_view.selection_model.select(index)
          cfg_list_view.focus_model.focus(index)
          cfg_list_view.scroll_to(index)
        end
        button
      end

      successors_layout = HBox.new(5)
      successors_layout.get_children << Label.new('Successors: ')
      successors_layout.get_children.add_all(@successor_buttons)

      get_children.add_all(@instrs_box, successors_layout)
    end
  end

  def instrs
    instrs_string = @basic_block.to_string_instrs
    if instrs_string.end_with?("\n")
      instrs_string[0...-1]
    else
      instrs_string
    end
  end

end

#
# The UI for the CFG as a wrapper for a ListView that is directly built
# from JRuby's CFG. In order to get a resizable UI element, a BorderPane is
# used
#
class ControlFlowGraphView < Java::javafx.scene.layout.BorderPane
  include JRubyFX

  def initialize(cfg)
    super()
    @cfg = cfg
    @cfg_list_view = ListView.new
    @bb_cells = FXCollections.observable_array_list([])
    @cfg.sorted_basic_blocks.each do |bb|
      bb_cell = BasicBlockBox.new(bb, cfg, @cfg_list_view)
      @bb_cells << bb_cell
    end
    @cfg_list_view.set_items(@bb_cells)
    set_center(@cfg_list_view)
  end

end
