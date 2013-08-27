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
  def initialize(cfg)
    @cfg = cfg
    @cfg.sorted_basic_blocks.each do |bb|
      # TODO create observable_list of basicblockView
    end
    # TODO inject observable_list to list_view constructor
    #super(bb_cells)
  end
  
end
