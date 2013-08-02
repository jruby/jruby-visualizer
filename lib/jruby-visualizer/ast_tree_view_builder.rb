require 'java'

java_import org.jruby.ast.visitor.AbstractNodeVisitor

class ASTTreeViewBuilder < AbstractNodeVisitor
  attr_accessor :tree_view
  
  def initialize(tree_view)
    super()
    @tree_view = tree_view
  end
  
  def default_visit(node)
    puts node
    node.childNodes.each do |child|
      child.accept(self)
    end
  end
end

if __FILE__ == $0
  require 'jruby'
  root = JRuby.parse("def foo; 42; end; foo")
  visitor = ASTTreeViewBuilder.new(nil)
  root.accept(visitor)
  visitor.default_visit(root)
end
