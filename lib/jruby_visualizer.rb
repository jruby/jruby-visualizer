#!/usr/bin/env jruby

require 'java'

require_relative 'jruby_visualizer/jruby_visualizer'

if __FILE__ == $0
  unless ARGV.length == 1
    usage_message = 
      %#No ruby input for the JRuby Visualizer
  Usage: 
    ./lib/jruby-visualizer.rb "def foo; 42; end; foo"
  or
    ./lib/jruby-visualizer.rb foo.rb#
    raise usage_message
  end
  ruby_input = ARGV[0]
  ruby_code = if ruby_input.end_with?('.rb')
    # TODO enable visualize with 'foo.rb' files
    File.read(ruby_input)
  else
    ruby_input
  end
  JRubyVisualizer.visualize(ruby_code)
end
