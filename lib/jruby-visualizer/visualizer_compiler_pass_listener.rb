require 'java'

class VisualizerCompilerPassListener
  java_implements org.jruby.org.jruby.ir.passes.CompilerPassListener
  include_package "org.jruby.ir.passes"
  import org.jruby.ir.IRScope
  
  java_signature 'public void alreadyExecuted(CompilerPass, IRScope, Object, boolean)'
  def already_executed(pass, scope, data, child_scope)
    nil
  end
  
  java_signature 'public void startExecute(CompilerPass, IRScope, boolean)'
  def start_execute(pass, scope, child_scope)
    nil
  end
  
  java_signature 'public void endExecute(CompilerPass, IRScope, Object, boolean)'
  def end_execute(pass, scope, data, child_scope)
    nil
  end
end
