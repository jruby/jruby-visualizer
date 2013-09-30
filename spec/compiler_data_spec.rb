require 'jruby_visualizer/compiler_data'
require 'jruby_visualizer_test_utils'

module CompilerDataTestUtils
  include JRubyVisualizerTestUtils
  @updated_ruby_code = false
  @updated_ast_root = false
  @updated_ir_scope = false
  
  def add_ruby_code_listener
    @compiler_data.ruby_code_property.add_invalidation_listener do |new_code|
      @updated_ruby_code = true
    end    
  end
  
  def add_ast_root_listener
    @compiler_data.ast_root_property.add_invalidation_listener do |new_ast|
      @updated_ast_root = true
    end
  end
  
  def add_ir_scope_listener
    @compiler_data.ir_scope_property.add_invalidation_listener do |new_ir_scope|
      @updated_ir_scope = true
    end    
  end
  
  def add_listeners
    add_ruby_code_listener
    add_ast_root_listener
    add_ir_scope_listener
  end
  
  def clear_updates
    @updated_ruby_code, @updated_ast_root, @updated_ir_scope = false, false, false
  end
  
  def should_has_ast(other_ast)
    @compiler_data.ast_root.to_s == other_ast.to_s
  end
  
  def should_has_ir_scope(other_ir_scope)
    @compiler_data.ir_scope.to_s == other_ir_scope.to_s
  end
  
end

describe CompilerData do
  include CompilerDataTestUtils
  
  before(:each) do
    @compiler_data = CompilerData.new
  end

  it "should update AST and IR Scope after updating ruby code" do
    add_listeners
    
    @compiler_data.ruby_code = "i = 1 + 2; puts i"
    @updated_ruby_code.should be_true
    @updated_ast_root.should be_true
    @updated_ir_scope.should be_true
  end
  
  it "should only update IR Scope after assigning a new AST" do
    add_listeners
    
    @compiler_data.ast_root = ast_for("j = 2; j") 
    @updated_ruby_code.should be_false
    @updated_ast_root.should be_true
    @updated_ir_scope.should be_true
  end
  
  it "should parse the AST implicitly" do
    ruby_code = "a = 1; b = 4; puts a + b"
    @compiler_data.ruby_code = ruby_code
    should_has_ast(ast_for(ruby_code))
  end
  
  it "should build the IR implicitly" do
    ast_root = ast_for("i = 42; puts i")
    @compiler_data.ast_root = ast_root
    should_has_ir_scope(ir_scope_for(ast_root))
  end
  
  it "should update IR on executing IR passes" do
    add_ir_scope_listener
    while @compiler_data.next_pass
      clear_updates
      @compiler_data.step_ir_passes
      @updated_ir_scope.should be_true
    end
  end
  
  it "should return nil after stepping all IR passes" do
    while @compiler_data.next_pass
      @compiler_data.step_ir_passes
    end
    @compiler_data.step_ir_passes.should be_nil
    @compiler_data.next_pass.should be_nil
  end
  
end
