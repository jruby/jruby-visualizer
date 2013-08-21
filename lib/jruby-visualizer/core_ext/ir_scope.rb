class Java::org::jruby::ir::IRScope
  ##
  # Return a key for storage into the ScopeRegistry.
  def key
    "#{get_name}[#{get_file_name}:#{get_line_number}]".to_sym
  end
end
