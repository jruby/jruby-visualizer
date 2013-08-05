require 'java'

class ASTTreeViewBuilder
  attr_accessor :tree_view
  
  def initialize(tree_view)
    @tree_view = tree_view
  end
  
  def build_view(node, parent_node=nil)
    puts node
    if node.child_nodes.size
      # non leaf node
      if parent_node
        # non root node
        node_tree_item = TreeItem.new(node.to_s)
        parent_node.children << node_tree_item
      else
        # root node
        parent_node = @tree_view.root = TreeItem.new(node.to_s)
      end
      node.child_nodes.each do |child|
        build_view(child, node_tree_item)
      end
    else 
      # leaf node
      node_tree_item = TreeItem.new()
    end
  end
end

if __FILE__ == $0
  require 'jruby'
  root = JRuby.parse("def foo; 42; end; foo")
  builder = ASTTreeViewBuilder.new(nil)
  builder.build_view(root)
  
  #visitor.default_visit(root)
end
