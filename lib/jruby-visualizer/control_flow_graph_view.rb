require 'jrubyfx'

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
    @instrs_box.set_style("-fx-font-family: monospaced")
    @successors = cfg.get_outgoing_destinations(@basic_block).to_a
    unless @successors.empty?
      @successor_buttons = @successors.map do |bb|
        button = Button.new(bb.to_s)
        button.set_on_action do
          # TODO rewrite this ugly code
          i = button.get_text.scan( /.*\[(\d+):.*\]/)[0][0]
          index = i.to_i - 1
          cfg_list_view.selection_model.select(index)
          cfg_list_view.focus_model.focus(index)
          cfg_list_view.scroll_to(index)
        end
        button
      end
    
      successors_layout = HBox.new(5)
      successors_layout.get_children << Label.new("Successors: ")
      successors_layout.get_children.add_all(@successor_buttons)
    
      get_children.add_all(@instrs_box, successors_layout)
    else
      get_children << @instrs_box
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

class ControlFlowGraphView < Java::javafx.scene.layout.BorderPane
  include JRubyFX
  
  def initialize(cfg)
    super()
    
    @cfg = cfg
    @cfg_list_view = ListView.new()
    @bb_cells = FXCollections.observable_array_list([])
    @cfg.sorted_basic_blocks.each do |bb|
      bb_cell = BasicBlockBox.new(bb, cfg, @cfg_list_view)
      @bb_cells << bb_cell
    end
    @cfg_list_view.set_items(@bb_cells)
    set_center(@cfg_list_view)
  end
  
end
