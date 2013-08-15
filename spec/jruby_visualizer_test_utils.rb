module JRubyVisualizerTestUtils
  def ast_for(ruby_code)
    JRuby::parse(ruby_code)
  end
  
  def ir_scope_for(ast_root)
    ir_manager = JRuby::runtime.ir_manager
    ir_manager.dry_run = true

    builder = 
      if JRuby::runtime.is1_9?
        org.jruby.ir.IRBuilder19
      else
        org.jruby.ir.IRBuilder
      end
    builder = builder.new(ir_manager)
    builder.build_root(ast_root)
  end
end
