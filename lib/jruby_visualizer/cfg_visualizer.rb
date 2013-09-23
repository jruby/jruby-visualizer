=begin
JRuby Visualizer
Copyright (C) 2013 The JRuby Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'jrubyfx'
require_relative 'jruby_visualizer'
require_relative 'ir_scope_registry'
require_relative 'control_flow_graph_view'

resource_root :images, File.join(File.dirname(__FILE__), 'ui', 'img'), 'ui/img'
fxml_root File.join(File.dirname(__FILE__), 'ui')

#
# UI to visualize the IR's Control Flow Graph (CFG)
# Currently as a list view with live links between the basic blocks
#
class CFGVisualizer < JRubyFX::Application
  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: 'Visualization of Control Flow Graphs (CFG)') do
      fxml(CFGVisualizerController, initialize: [compiler_data])
      icons.add(Image.new(resource_url(:images, 'jruby-icon-32.png').to_s))
      show
    end
  end
end

#
# This controller connects the CompilerData to the CFG View and
# handles opening/updating tabs for CFGs
#
class CFGVisualizerController
  include JRubyFX::Controller
  fxml 'cfg-view.fxml'

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
      cfg = get_selected_scope.cfg!
      tab.set_content(ControlFlowGraphView.new(cfg))
      tabs << tab
      # set focus on selected tab
      @cfg_scopes_view.selection_model.select(tab)
    end
  end

  def get_selected_scope
    @ir_registry.scopes[@selected_scope.to_sym]
  end

  def update_tabs
    @cfg_scopes_view.tabs.each do |tab|
      scope_name = tab.text
      # TODO read and diff on custom cfg objects
      cfg = @ir_registry.scopes[scope_name.to_sym].cfg!
      # TODO listen to events if the ir scope changes
      tab.set_content(ControlFlowGraphView.new(cfg))
    end
  end
  
end

if __FILE__ == $PROGRAM_NAME
  JRubyVisualizer.compiler_data = CompilerData.new(
    "\nclass Foo\n\ndef bar; 42; end; end;\nFoo.new.bar")
  CFGVisualizer.launch
end
