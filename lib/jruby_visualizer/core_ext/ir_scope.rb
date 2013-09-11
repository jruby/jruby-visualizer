class Java::org::jruby::ir::IRScope
  ##
  # Return a key for storage into the ScopeRegistry.
  def key
    "#{get_name}[#{get_file_name}:#{get_line_number}]".to_sym
  end

  ##
  # return the CFG and if it is not created yet construct it as
  # a side-effect
  def cfg!
    buildCFG unless get_cfg
    get_cfg
  end
end
