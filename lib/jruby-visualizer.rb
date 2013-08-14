#!/usr/bin/env jruby

require 'java'

require_relative 'jruby-visualizer/jruby_visualizer'

if __FILE__ == $0
  unless ARGV.length == 1
    raise %Q#No ruby input for the JRuby Visualizer\nUsage as argument: "def foo; puts 42; end; foo" or foo.rb#
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