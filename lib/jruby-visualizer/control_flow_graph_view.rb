require 'jrubyfx'

class BasicBlockListCell < Java::javafx.scence.control.ListCell
  include JRubyFX
  
  def initialize(basic_block, cfg)
    # TODO compose with a textarea and buttons for successors of this basic block
    @basic_block = basic_block
    @instrs_box = TextArea.new(@basic_block.to_string_instrs)
    # TODO group instrs_box and successors as VBox
    @successors = Array.new(cfg.outgoing_destinations(@basic_block))
  end
  
  def updateItem(item, empty)
    super(item, empty)
    
    # TODO update layout with a new layout manager
    # |bb_instrs|links to successors|
    if empty
      set_text(nil)
      set_graphic(nil)
    else
      set_text(@basic_block.to_s)
      # TODO use custom layout on instrs and successors
      set_graphic(@instrs_box)
    end
    
  end
  
end

class ControlFlowGraphView < Java::javafx.scene.control.ListView
  include JRubyFX
  
  def initialize(cfg)
    @cfg = cfg
    bb_cells = @cfg.sorted_basic_blocks.map do |bb|
      BasicBlockListCell.new(bb, @cfg)
    end
    @bb_cells = FXCollections.observable_array_list(bb_cells)
    super(@bb_cells)
  end
  
end
