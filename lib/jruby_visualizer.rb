#!/usr/bin/env jruby

require 'java'

require_relative 'jruby_visualizer/jruby_visualizer'

if __FILE__ == $0
  JRubyVisualizer.visualize_with_argv(ARGV)
end
