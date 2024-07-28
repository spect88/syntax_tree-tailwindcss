# frozen_string_literal: true

module SyntaxTree
  module ERB
    # A base ERB Visitor class that returns a deep copy of the AST.
    # It can be subclassed to mutate some parts of the AST and keep everything
    # else as it was.
    #
    # Ideally this class (or equivalent) would exist within SyntaxTree::ERB gem.
    class MutationVisitor
      def visit(node)
        node&.accept(self)
      end

      def copy_and_visit_children(node)
        node.dup.tap do |clone|
          clone.instance_variables.each do |name|
            var = clone.instance_variable_get(name)
            clone.instance_variable_set(
              name,
              case var
              when Array
                var.map { |child| visit(child) }
              when SyntaxTree::ERB::Node
                visit(var)
              else
                var
              end
            )
          end
        end
      end

      alias visit_attribute copy_and_visit_children
      alias visit_block copy_and_visit_children
      alias visit_char_data copy_and_visit_children
      alias visit_closing_tag copy_and_visit_children
      alias visit_doctype copy_and_visit_children
      alias visit_document copy_and_visit_children
      alias visit_erb copy_and_visit_children
      alias visit_erb_block copy_and_visit_children
      alias visit_erb_case copy_and_visit_children
      alias visit_erb_case_when copy_and_visit_children
      alias visit_erb_close copy_and_visit_children
      alias visit_erb_comment copy_and_visit_children
      alias visit_erb_content copy_and_visit_children
      alias visit_erb_do_close copy_and_visit_children
      alias visit_erb_else copy_and_visit_children
      alias visit_erb_end copy_and_visit_children
      alias visit_erb_if copy_and_visit_children
      alias visit_erb_yield copy_and_visit_children
      alias visit_html copy_and_visit_children
      alias visit_html_comment copy_and_visit_children
      alias visit_html_string copy_and_visit_children
      alias visit_new_line copy_and_visit_children
      alias visit_opening_tag copy_and_visit_children
      alias visit_token copy_and_visit_children
    end
  end
end
