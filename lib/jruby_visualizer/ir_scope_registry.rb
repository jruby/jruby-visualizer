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

require_relative 'core_ext/ir_scope'

#
# Registry for IRScopes, to access them by key without nesting of scopes
#
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
