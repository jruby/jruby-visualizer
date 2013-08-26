require 'jrubyfx'

class BasicBlockView < Java::javafx.scence.control.ListCell
  # TODO compose with a textarea and buttons for successors of this basic block
end

class ControlFlowGraphView < Java::javafx.scene.control.ListView
  def initialize
    # TODO iterate cfg sorted_basic_blocks
    # then create for each basic_block a BasicBlockView as Cell within this view
    # use the factory thing for cell creation
  end
end
