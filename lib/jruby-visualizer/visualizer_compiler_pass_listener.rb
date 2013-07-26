require 'java'

class VisualizerCompilerPassListener
  java_implements org.jruby.ir.passes.CompilerPassListener
  
  def already_executed(pass, scope, data, child_scope)
    puts "PassListener inside already_executed"
    nil
  end
  
  def start_execute(pass, scope, child_scope)
    puts "PassListener inside start_execute"
    nil
  end
  
  def end_execute(pass, scope, data, child_scope)
    puts "PassListener inside end_execute"
    nil
  end
end
