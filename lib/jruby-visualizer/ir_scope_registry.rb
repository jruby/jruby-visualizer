
class IRScopeRegistry
  attr_reader :scopes
  
  def initialize(root_scope)
    @scopes = {}
    fill_registry(root_scope)
  end
  
  def fill_registry(ir_scope)
    @scopes[ir_scope.to_s] = ir_scope
    ir_scope.lexical_scopes.each do |lex_scope|
      fill_registry(lex_scope)
    end
  end
  
  def clear
    @scopes = {}
  end
  
end
