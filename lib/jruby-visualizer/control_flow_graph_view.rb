require 'jrubyfx'

class BasicBlockListCell < Java::javafx.scene.control.ListCell
  include JRubyFX
  
  def initialize(basic_block, cfg)
    super()
    
    @bb_box = BasicBlockBox.new(basic_block, cfg, list_view)
    set_item(@bb_box)
  end
  
  def updateItem(item, empty)
    super(item, empty)
    
    # TODO update layout with a new layout manager
    # |bb_instrs|links to successors|
    if empty
      #set_text(nil)
      #set_graphic(nil)
    else
      #set_text(@bb_box.basic_block.to_s)
      # TODO use custom layout on instrs and successors
      #set_graphic(@bb_box)
    end
  end
  
end

class BasicBlockBox < Java::javafx.scene.layout.VBox
  include JRubyFX
  
  attr_reader :basic_block, :instrs_box, :successors, :successor_buttons
  
  def initialize(basic_block, cfg, cfg_list_view)
    super(5)
    @basic_block = basic_block
    @instrs_box = TextArea.new(@basic_block.to_string_instrs)
    @successors = cfg.get_outgoing_destinations(@basic_block).to_a
    unless @successors.empty?
      @successor_buttons = @successors.map do |bb|
        button = Button.new(bb.to_s)
        button.set_on_action do
          # TODO retrieve target index from button
          i = button.get_text.scan( /.*\[(\d+):.*\]/)[0][0]
          index = i.to_i - 1
          p(index)
          # then select the index inside of the selection_model
          cfg_list_view.selection_model.select(index)
          cfg_list_view.focus_model.focus(index)
          p(cfg_list_view)
          p(cfg_list_view.class)
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
  
end

class ControlFlowGraphView < Java::javafx.scene.layout.BorderPane
  include JRubyFX
  
  def initialize(cfg)
    super()
    
    @cfg = cfg
    @cfg_list_view = ListView.new()
    @bb_cells = FXCollections.observable_array_list([])
    @cfg.sorted_basic_blocks.each do |bb|
      #bb_cell = BasicBlockListCell.new(bb, cfg)
      bb_cell = BasicBlockBox.new(bb, cfg, @cfg_list_view)
      @bb_cells << bb_cell
    end
    @cfg_list_view.set_items(@bb_cells)
    set_center(@cfg_list_view)
  end
  
end
