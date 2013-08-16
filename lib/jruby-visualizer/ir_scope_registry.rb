
class IRScopeRegistry
  
  attr_reader :scopes
  
  def self.ir_scope_to_key(ir_scope)
    "#{ir_scope.get_name}[#{ir_scope.get_file_name}:#{ir_scope.get_line_number}]".to_sym
  end
  
  def initialize(root_scope)
    @scopes = {}
    fill_registry(root_scope)
  end
  
  def fill_registry(ir_scope)
    @scopes[self.class.ir_scope_to_key(ir_scope)] = ir_scope
    ir_scope.lexical_scopes.each do |lex_scope|
      fill_registry(lex_scope)
    end
  end
  
  def clear
    @scopes = {}
  end
  
end
