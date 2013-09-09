module IRPrettyPrinter
  
  def self.pretty_ir(scope, indent="")
    instrs = if scope.cfg
      # read instrs from control flow graph
      scope.cfg.sorted_basic_blocks.inject([]) do |cfg_instrs, bb|
        cfg_instrs += bb.instrs
      end
    else
      # if no pass has been executed get them directly without cfg
      scope.instrs
    end
    pretty_str = instrs.map do |instr|
      f_str = "%s\s\s%s" % [indent, instr]
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