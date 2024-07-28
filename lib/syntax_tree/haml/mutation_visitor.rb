# frozen_string_literal: true

module SyntaxTree
  module Haml
    class MutationVisitor
      # A base Haml Visitor class that returns a deep copy of the AST.
      # It can be subclassed to mutate some parts of the AST and keep everything
      # else as it was.
      #
      # Ideally this class (or equivalent) would existing within SyntaxTree::Haml gem.
      def visit(node)
        node&.accept(self)
      end

      def copy_and_visit_children(node)
        # Haml::Parser::ParseNode has these main attributes
        # - value: nil | Hash
        # - children: [ParseNode]
        # - parent: ParseNode
        node.dup.tap do |clone|
          clone.value = node.value.dup unless node.value.nil?
          clone.children =
            node.children.map do |child|
              visit(child).tap { |child_copy| child_copy.parent = clone }
            end
        end
      end

      alias visit_comment copy_and_visit_children
      alias visit_doctype copy_and_visit_children
      alias visit_filter copy_and_visit_children
      alias visit_haml_comment copy_and_visit_children
      alias visit_plain copy_and_visit_children
      alias visit_root copy_and_visit_children
      alias visit_script copy_and_visit_children
      alias visit_silent_script copy_and_visit_children
      alias visit_tag copy_and_visit_children
    end
  end
end
