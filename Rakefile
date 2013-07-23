if !defined? RUBY_ENGINE || RUBY_ENGINE != "jruby"
  puts "Rake must be run from JRuby for Ant integration"
  exit 1
end

require 'rspec/core/rake_task'
#require 'ant'
require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:spec]

#ant_import # load all ant targets as rake tasks

desc "Run specs"
RSpec::Core::RakeTask.new

desc "Clean all build artifacts"
task :clean do
  rm_rf "pkg" if File.exists? "pkg"
end
