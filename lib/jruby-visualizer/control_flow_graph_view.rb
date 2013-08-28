require 'jrubyfx'

class BasicBlockListCell < Java::javafx.scene.control.ListCell
  include JRubyFX
  
  def initialize(basic_block, cfg)
    super()
    # TODO compose with a textarea and buttons for successors of this basic block
    @basic_block = basic_block
    p(@basic_block.to_string_instrs)
    p(@basic_block.to_s)
    @instrs_box = TextArea.new(@basic_block.to_string_instrs)
    # TODO group instrs_box and successors as VBox
    @successors = cfg.get_outgoing_destinations(@basic_block)
  end
  
  def updateItem(item, empty)
    super(item, empty)
    
    # TODO update layout with a new layout manager
    # |bb_instrs|links to successors|
    if empty
      set_text(nil)
      set_graphic(nil)
    else
      set_text(@basic_block.to_string_instrs)
      # TODO use custom layout on instrs and successors
      set_graphic(@instrs_box)
    end
  end
  
end

class BasicBlockBox < Java::javafx.scene.layout.VBox
  include JRubyFX
  
  attr_reader :basic_block, :instrs_box, :successors, :successor_buttons
  
  def initialize(basic_block, cfg)
    super(5)
    @basic_block = basic_block
    @instrs_box = TextArea.new(@basic_block.to_string_instrs)
    @successors = cfg.get_outgoing_destinations(@basic_block).to_a
    unless @successors.empty?
      @successor_buttons = @successors.map { |bb| Button.new(bb.to_s) }
    
      successors_layout = HBox.new(5)
      successors_layout.get_children << Label.new("Successors: ")
      successors_layout.get_children.add_all(@successor_buttons)
    
      get_children.add_all(@instrs_box, successors_layout)
    else
      get_children << @instrs_box
    end
  end
  
end

class ControlFlowGraphView < Java::javafx.scene.control.ListView
  include JRubyFX
  
  def initialize(cfg)
    @cfg = cfg
    @bb_cells = FXCollections.observable_array_list([])
    @cfg.sorted_basic_blocks.each do |bb|
      #bb_cell = BasicBlockListCell.new(bb, cfg)
      bb_cell = BasicBlockBox.new(bb, cfg)
      @bb_cells << bb_cell
    end
    super(@bb_cells)
  end
  
end
