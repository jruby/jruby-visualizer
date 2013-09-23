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

#
# Retrieve a nicely formatted string from JRuby's IRScope
#
module IRPrettyPrinter
  
  def self.pretty_ir(scope, indent='')
    instrs = if scope.cfg
      # read instrs from control flow graph
      scope.cfg.sorted_basic_blocks.reduce([]) do |cfg_instrs, bb|
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

