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
  
  attr_reader :compiler_data, :ir_scopes
  
  def initialize(compiler_data)
    @compiler_data = compiler_data
    
    # read scopes into the registry
    @ir_scopes = IRScopeRegistry.new(@compiler_data.ir_scope)
    # listen to changes of the ir_scope property
    @compiler_data.ir_scope_property.add_invalidation_listener do |new_scope_property|
      root_scope = new_scope_property.get
      @ir_scopes.clear
      @ir_scopes.fill_registry(root_scope)
      # TODO read the new scopes into the UI
    end
  end
  
end

if __FILE__ == $0
  JRubyVisualizer.compiler_data = CompilerData.new(
    "a = 1 + 4 + 7;\nc = nil;\nj = 1;\ni = 3 + j;\nputs i")
  CFGVisualizer.launch
end