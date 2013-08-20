require 'jrubyfx'
require_relative 'jruby_visualizer'
require_relative 'ir_scope_registry'

fxml_root File.join(File.dirname(__FILE__), "ui")

class CFGVisualizer < JRubyFX::Application
  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: "Visualization of Control Flow Graphs (CFG)") do
      fxml(CFGVisualizerController, initialize: [compiler_data])
      show
    end
  end
end

class CFGVisualizerController
  include JRubyFX::Controller
  fxml "cfg-view.fxml"
  
  attr_reader :compiler_data, :ir_registry
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
    
    # read scopes into the registry
    @ir_registry = IRScopeRegistry.new(@compiler_data.ir_scope)
    read_registry_into_selector
    # listen to changes of the ir_scope property
    @compiler_data.ir_scope_property.add_invalidation_listener do |new_scope_property|
      root_scope = new_scope_property.get
      @ir_registry.clear
      @ir_registry.fill_registry(root_scope)
      read_registry_into_selector
      update_tabs
    end
  end
  
  def read_registry_into_selector
    scopes_keys = @ir_registry.scopes.keys.map do |key|
      key.to_s
    end
    scopes_keys.sort!
    @ir_scope_selector.items = FXCollections.observable_array_list(scopes_keys)
    @ir_scope_selector.value = @selected_scope = scopes_keys[0]
  end
  
  def select_scope
    @selected_scope = @ir_scope_selector.value
    open_cfg_tab
  end
  
  def open_cfg_tab
    if @selected_scope.nil?
      return
    end
    
    tabs = @cfg_scopes_view.tabs
    is_tab_opened = tabs.find do |tab|
      # get string value from StringProperty name
      tab.text == @selected_scope
    end
    
    unless is_tab_opened
      tab = Tab.new(@selected_scope)
      ir_scope = get_selected_scope
      if ir_scope.cfg.nil?
        ir_scope.buildCFG
      end
      cfg = ir_scope.cfg
      content = "Graph: #{cfg.to_string_graph}\nInstr: #{cfg.to_string_instrs}"
      # TODO use custom cfg objects and graph drawing instead of text representation
      tab.set_content(TextArea.new(content))
      tabs << tab
      # set focus on selected tab
      @cfg_scopes_view.selection_model.select(tab)
    end
  end
  
  def get_selected_scope
    @ir_registry.scopes[@selected_scope.to_sym]
  end
  
  def update_tabs
    tabs = @cfg_scopes_view.tabs
    tabs.each do |tab|
      scope_name = tab.text
      ir_scope = @ir_registry.scopes[scope_name.to_sym]
      if ir_scope.cfg.nil?
        ir_scope.buildCFG
      end
      # TODO read and diff on custom cfg objects
      cfg = ir_scope.cfg
      content = "Graph: #{cfg.to_string_graph}\nInstr: #{cfg.to_string_instrs}"
      # TODO listen to events if the ir scope changes
      tab.set_content(TextArea.new(content))
    end
  end
  
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "\nclass Foo\n\ndef bar; 42; end; end;\nFoo.new.bar")
  CFGVisualizer.launch
end