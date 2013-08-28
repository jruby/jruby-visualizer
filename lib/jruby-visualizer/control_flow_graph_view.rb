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

class BasicBlockView < Java::javafx.scene.layout.VBox
  include JRubyFX
  
  def initialize(basic_block, cfg)
    super(5)
    @basic_block = basic_block
    p(@basic_block.to_string_instrs)
    p(@basic_block.to_s)
    @instrs_box = TextArea.new(@basic_block.to_string_instrs)
    # TODO group instrs_box and successors as VBox
    @successors = cfg.get_outgoing_destinations(@basic_block)
    successors_names = @successors.inject("successors: ") do |res,bb|  
      res + ' ' + bb.to_s
    end
    get_children.add_all(@instrs_box, Label.new(successors_names))
  end
  
end

class ControlFlowGraphView < Java::javafx.scene.control.ListView
  include JRubyFX
  
  def initialize(cfg)
    @cfg = cfg
    @bb_cells = FXCollections.observable_array_list([])
    @cfg.sorted_basic_blocks.each do |bb|
      #bb_cell = BasicBlockListCell.new(bb, cfg)
      bb_cell = BasicBlockView.new(bb, cfg)
      #bb_cell = TextArea.new(bb.to_string_instrs)
      @bb_cells << bb_cell
    end
    super(@bb_cells)
  end
  
end
