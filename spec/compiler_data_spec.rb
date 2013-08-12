require 'jruby-visualizer/compiler_data'

module CompilerDataTestUtils
  @updated_ruby_code = false
  @updated_ast_root = false
  
  def add_ruby_code_listener
    @compiler_data.ruby_code_property.add_change_listener do |new_code|
      @updated_ruby_code = true
    end    
  end
  
  def add_ast_root_listener
    @compiler_data.ast_root_property.add_change_listener do |new_ast|
      @updated_ast_root = true
    end
  end
  
  def add_listeners
    add_ruby_code_listener
    add_ast_root_listener
  end
  
  def clear_updates
    @updated_ruby_code, @updated_ast_root = false, false
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
  end
end

