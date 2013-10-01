require 'jruby_visualizer/ir_scope_registry'
require 'jruby_visualizer_test_utils'

describe IRScopeRegistry do
  include JRubyVisualizerTestUtils

  before(:each) do
    @ruby_code = "\nclass Foo\n\ndef bar; 42; end; end;\nFoo.new.bar"
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
    file_scope_symbol = @root_scope.key
    file_scope_symbol.should be_an_instance_of Symbol
    file_scope_symbol.should == :'-[-:0]'
  end
  
  it "should contain the file scope - at line 0" do
   @ir_reg.scopes.should include(:'-[-:0]')
  end
  
  it "should contain the Foo (class) scope at line 1" do
    @ir_reg.scopes.should include(:'Foo[-:1]')
  end
  
  it "should contain the scope for the method bar at line 3" do
    @ir_reg.scopes.should include(:'bar[-:3]')
  end
  
  it "should refill correctly after clearing" do
    @ir_reg.clear
    @ir_reg.fill_registry(@root_scope.lexical_scopes.get(0))
    @ir_reg.scopes.size.should be(2)
    @ir_reg.scopes.should include(:'Foo[-:1]')
  end
  
end

