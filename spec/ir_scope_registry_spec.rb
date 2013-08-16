require 'jruby-visualizer/ir_scope_registry'
require 'jruby_visualizer_test_utils'

describe IRScopeRegistry do
  include JRubyVisualizerTestUtils
  
  before(:each) do
    @ruby_code = "\nclass Foo\ndef foo; 42; end; end;\nFoo.new.foo"
    ast_root = ast_for(@ruby_code)
    @root_scope = ir_scope_for(ast_root)
    @ir_reg = IRScopeRegistry.new(@root_scope)
  end

  it "should be empty after clearing" do
    @ir_reg.clear
    @ir_reg.scopes.should be_empty
  end
  
  it "should contain three scopes for #{@ruby_code}" do
    @ir_reg.scopes.size.should be(3)
  end
  
  it "should format the file scope - to a symbol" do
    file_scope_symbol = IRScopeRegistry.ir_scope_to_key(@root_scope)
    file_scope_symbol.should be_an_instance_of Symbol
    file_scope_symbol.should == :"-[-:0]"
  end
  
end

