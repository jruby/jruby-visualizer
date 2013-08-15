require 'jruby-visualizer/ir_scope_registry'
require 'jruby_visualizer_test_utils'

describe IRScopeRegistry do
  include JRubyVisualizerTestUtils
  
  before(:each) do
    ast_root = ast_for("class Foo; def foo; 42; end; end; Foo.new.foo")
    @root_scope = ir_scope_for(ast_root)
    @ir_reg = IRScopeRegistry.new(@root_scope)
  end

  it "should be empty after clearing" do
    @ir_reg.clear
    @ir_reg.scopes.empty?.should be_true
  end
end

