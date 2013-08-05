require 'java'

#java_import org.jruby.ast.visitor.AbstractNodeVisitor

class ASTTreeViewBuilder #< AbstractNodeVisitor
  attr_accessor :tree_view
  
  def initialize(tree_view)
    super()
    @tree_view = tree_view
  end
  
  def build_view(node, parent_node=nil)
    puts node
    if node.child_nodes.size
      # non leaf node
      node.child_nodes.each do |child|
        #default_visit(child)
        build_view(child, node)
      end
    else 
      # leaf node 
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
