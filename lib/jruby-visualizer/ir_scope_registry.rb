require_relative 'core_ext/ir_scope'

class IRScopeRegistry
  
  attr_reader :scopes
  
  def initialize(root_scope)
    @scopes = {}
    fill_registry(root_scope)
  end
  
  def fill_registry(ir_scope)
    @scopes[ir_scope.key] = ir_scope
    ir_scope.lexical_scopes.each { |lex_scope| fill_registry(lex_scope) }
  end
  
  def clear
    @scopes = {}
  end
  
end
