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

class VisualizerCompilerPassListener
  java_implements org.jruby.ir.passes.CompilerPassListener

  def already_executed(pass, scope, data, child_scope)
    # TODO add implementation logic
    #puts "PassListener inside already_executed"
    nil
  end

  def start_execute(pass, scope, child_scope)
    # TODO implementation logic
    #puts "PassListener inside start_execute"
    nil
  end

  def end_execute(pass, scope, data, child_scope)
    # TODO diff on start_execute or already_executed
    #puts "PassListener inside end_execute"
    nil
  end
end
