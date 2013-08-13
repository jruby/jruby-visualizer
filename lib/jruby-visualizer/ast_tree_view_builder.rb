require 'java'

class ASTTreeViewBuilder
  include JRubyFX
  attr_accessor :tree_view
  
  def initialize(tree_view)
    @tree_view = tree_view
  end
  
  def build_tree_item(node)
    node_information =
      if node.is_a? Java::org.jruby.ast.types.INameNode
        name_node = node.to_java(Java::org.jruby.ast.types.INameNode)
        ":#{name_node.name}"
      else
        ""
      end
    
    node_string = "#{node.node_name}#{node_information} #{node.position.start_line}"
    TreeItem.new(node_string)
  end
  
  def build_view(node, parent_node=nil)
    if parent_node.nil?
      # root node
      parent_node = @tree_view.root = build_tree_item(node)
    else
      # non root node
      node_tree_item = build_tree_item(node)
      parent_node.children << node_tree_item
      parent_node = node_tree_item
    end
    
    if node.child_nodes.size
      node.child_nodes.each do |child|
        build_view(child, parent_node)
      end
    end
  end
end

if __FILE__ == $0
  require 'jruby'
  root = JRuby.parse("def foo; 42; end; foo")
  builder = ASTTreeViewBuilder.new(nil)
  builder.build_view(root)
end
