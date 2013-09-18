#!/usr/bin/env jruby

require 'java'

require_relative 'jruby_visualizer/jruby_visualizer'

if __FILE__ == $PROGRAM_NAME
  JRubyVisualizer.visualize_with_argv
end
