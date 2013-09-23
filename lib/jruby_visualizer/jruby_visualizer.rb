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

require 'java'
require 'jruby'
require_relative 'visualizer_compiler_pass_listener'
require_relative 'visualizer_main_app'

#
# The Visualizer module enables to launch the visualizer components via
# an API call or ARGV
#
module JRubyVisualizer
  @@main_app = nil
  @@compiler_data = nil

  def self.compiler_data
    @@compiler_data
  end

  def self.compiler_data=(new_data)
    @@compiler_data = new_data
  end

  def self.launched?
    !!@@main_app
  end

  def self.launch
    if launched?
      return
    end
    unless @@compiler_data
      raise 'Cannot launch Visualizer without a ComiplerData object'
    end
    VisualizerMainApp.launch
    @@main_app = VisualizerMainApp
  end

  def self.inject_pass_listener
    # create and add listener
    vis_pass_listener = VisualizerCompilerPassListener.new
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.add_listener(vis_pass_listener)

    # activate visualization listener
    JRuby::IR.visualize = true
  end

  def self.pass_listener?
    JRuby::IR.visualize
  end

  def self.visualize(ruby_code)
    unless pass_listener?
      inject_pass_listener
    end
    @@compiler_data = CompilerData.new(ruby_code)
    # launch App with Ruby code as input
    launch
  end

  def self.visualize_with_argv
    unless ARGV.length == 1
      usage_message =
      %#No ruby input for the JRuby Visualizer
  Usage: 
    ./lib/jruby_visualizer.rb "def foo; 42; end; foo"
  or
    ./lib/jruby_visualizer.rb foo.rb#
      raise usage_message
    end
    ruby_input = ARGV[0]
    ruby_code =
    if ruby_input.end_with?('.rb')
      File.read(ruby_input)
    else
      ruby_input
    end
    visualize(ruby_code)
  end

end

if __FILE__ == $PROGRAM_NAME
  vis = JRubyVisualizer
  vis.visualize('def foo; 42; end; foo')
end

