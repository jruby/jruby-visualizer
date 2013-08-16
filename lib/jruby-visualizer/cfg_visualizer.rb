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
      # TODO read the new scopes into the UI
      read_registry_into_selector
    end
  end
  
  def read_registry_into_selector
    scopes_keys = @ir_registry.scopes.keys.map do |key|
      key.to_s
    end
    scopes_keys.sort!
    @ir_scope_selector.items = FXCollections.observable_array_list(scopes_keys)
    @ir_scope_selector.value = scopes_keys[0]
    
  end
  
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "\nclass Foo\n\ndef bar; 42; end; end;\nFoo.new.bar")
  CFGVisualizer.launch
end