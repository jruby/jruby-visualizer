# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jruby_visualizer/version"

files = `git ls-files -- lib/* spec/* sample/*`.split("\n")

Gem::Specification.new do |s|
  s.name        = 'jruby-visualizer'
  s.version     = JRubyVisualizer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Maximilian Konzack', 'Thomas E. Enebo']
  s.email       = ['maximilian.konzack@gmail.com', 'tom.enebo@gmail.com']
  s.homepage    = 'http://github.com/jruby/jruby-visualizer'
  s.summary     = %q{A Gem for visualizing JRuby compiler artifacts}
  s.description = %q{A Gem for visualizing JRuby compiler artifacts}

  s.rubyforge_project = "jruby-visualizer"

  s.files         = files
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.has_rdoc      = true
end
