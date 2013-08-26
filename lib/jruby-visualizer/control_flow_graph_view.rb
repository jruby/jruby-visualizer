require 'jrubyfx'

class BasicBlockListCell < Java::javafx.scence.control.ListCell
  def initialize
    # TODO compose with a textarea and buttons for successors of this basic block
  end
  
  def updateItem
    # TODO update layout with a new layout manager
    # |bb_instrs|links to successors|
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
