require 'java'
require 'jrubyfx'

class ASTTreeItem < Java::javafx.scene.control.TreeItem
  include JRubyFX
  
  attr_reader :node
  
  def initialize(node)
    @node = node
    super(node_string)
    set_expanded(true)
  end
  
  def node_string
    node_information = @node.respond_to?(:name) ? ":#{@node.name}" : ""
    "#{@node.node_name}#{node_information} #{@node.position.start_line}"    
  end
  
end

class ASTTreeViewBuilder
  include JRubyFX
  attr_accessor :tree_view
  
  def initialize(tree_view)
    @tree_view = tree_view
  end
  
  def build_tree_item(node)
    ASTTreeItem.new(node)
  end

  def build_view(root)
    @tree_view.root = build_tree_item(root)
    root.child_nodes.each { |child| build_view_inner(child, @tree_view.root) }
  end
  
  def build_view_inner(node, parent_item)
    tree_item = build_tree_item(node)
    parent_item.children << tree_item
    node.child_nodes.each { |child| build_view_inner(child, tree_item) }
  end
  private :build_view_inner
end

if __FILE__ == $0
  require 'jruby'
  root = JRuby.parse("def foo; 42; end; foo")
  builder = ASTTreeViewBuilder.new(nil)
  builder.build_view(root)
end
