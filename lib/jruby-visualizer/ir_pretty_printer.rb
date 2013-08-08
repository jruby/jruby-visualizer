module IRPrettyPrinter
  
  def self.pretty_ir(scope, indent="")
    i = 0
    pretty_str = scope.instrs.map do |instr|
      f_str = "%s%3i\s\s%s" % [indent, i, instr]
      i += 1
      f_str 
    end
    pretty_str = [indent + scope.to_s] + pretty_str
    scope.lexical_scopes.each do |lex_scope|
      pretty_str += pretty_ir(lex_scope, indent + "\s" * 4)
    end
    pretty_str
  end

  def self.print_ir(scope)
    instrs = pretty_ir(scope)
    instrs.each do |instr|
      puts instr
    end
  end
  
  def self.pretty_string(scope)
    instrs = pretty_ir(scope)
    instrs.join("\n")
  end
  
end