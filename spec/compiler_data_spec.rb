require 'jruby-visualizer/compiler_data'

describe CompilerData do
  before(:each) do
    @compiler_data = CompilerData.new
    puts @compiler_data
  end

  it "should update AST and IR Scope after updating ruby code" do
    updated_ruby_code = false
    @compiler_data.ruby_code_property.add_change_listener do |new_code|
      updated_ruby_code = true
    end
    
    updated_ast_root = false
    @compiler_data.ast_root_property.add_change_listener do |new_ast|
      updated_ast_root = true
    end
    
    @compiler_data.ruby_code = "i = 1 + 2; puts i"
    updated_ruby_code.should be_true
    updated_ast_root.should be_true
  end
end

