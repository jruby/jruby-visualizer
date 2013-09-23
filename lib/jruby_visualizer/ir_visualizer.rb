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
require 'diffy'
require_relative 'ir_pretty_printer'
require_relative 'jruby_visualizer'

resource_root :images, File.join(File.dirname(__FILE__), 'ui', 'img'), 'ui/img'
fxml_root File.join(File.dirname(__FILE__), 'ui')

#
# Visualizer for JRuby's Intermediate Representation (IR)
# displaying all IR Scopes with its lexical nesting
# and
# diffs on the IR, if it has changed (after executing a compiler pass)
#
class IRVisualizer < JRubyFX::Application

  def start(stage)
    compiler_data = JRubyVisualizer.compiler_data
    with(stage, title: 'Intermediate Representation (IR) Visualizer') do
      fxml(IRVisualizerController, initialize: [compiler_data])
      icons.add(Image.new(resource_url(:images, 'jruby-icon-32.png').to_s))
      show
    end
  end
end

#
# The controller loads the UI file and takes care of the diffs and
# updating the UI
#
class IRVisualizerController
  include JRubyFX::Controller
  fxml 'ir-view.fxml'

  attr_reader :compiler_data

  def initialize(compiler_data)
    @compiler_data = compiler_data
    pretty_ir_string = IRPrettyPrinter.pretty_string(@compiler_data.ir_scope)
    @ir_view.text = @new_ir_string = @previous_ir_string = pretty_ir_string

    @compiler_data.ir_scope_property.add_invalidation_listener do |new_scope_property|
      @previous_ir_string = @new_ir_string
      @new_ir_string = IRPrettyPrinter.pretty_string(new_scope_property.get)
      diff_string = Diffy::Diff.new(@previous_ir_string, @new_ir_string).to_s
      @ir_view.text =
      if diff_string.empty?
        @new_ir_string
      else
        diff_string
      end
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  JRubyVisualizer.compiler_data = CompilerData.new(
    "a = 1 + 4 + 7;\nc = nil;\nj = 1;\ni = 3 + j;\nputs i")
  IRVisualizer.launch
end

