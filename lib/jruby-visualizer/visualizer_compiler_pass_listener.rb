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
