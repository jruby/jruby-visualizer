=begin
JRuby Visualizer
Copyright (C) 2013 The JRuby Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'java'
require 'jrubyfx'

#
# Custom TreeItem, to store the JRuby's AST Node within the item
#
class ASTTreeItem < Java::javafx.scene.control.TreeItem
  include JRubyFX

  attr_reader :node

  def initialize(node)
    @node = node
    super(node_string)
    set_expanded(true)
  end

  def node_string
    node_information = @node.respond_to?(:name) ? ":#{@node.name}" : ''
    "#{@node.node_name}#{node_information} #{@node.position.start_line}"
  end

end


#
# Builder for the custom TreeItem from an usual JRuby AST
#
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

if __FILE__ == $PROGRAM_NAME
  require 'jruby'
  root = JRuby.parse('def foo; 42; end; foo')
  builder = ASTTreeViewBuilder.new(nil)
  builder.build_view(root)
end
