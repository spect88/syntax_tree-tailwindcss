# frozen_string_literal: true

require "syntax_tree/erb/mutation_visitor"

module SyntaxTree
  module Tailwindcss
    class ErbMutationVisitor < SyntaxTree::ERB::MutationVisitor
      def initialize(sorter)
        super()
        @sorter = sorter
        @ruby_visitor = SyntaxTree::Tailwindcss::RubyMutationVisitor.new(sorter)
      end

      # Rewrite `<%= tag.span class: 'foo bar' %>`
      def visit_erb_content(node)
        node.dup.tap do |clone|
          clone.instance_variable_set(:@value, clone.value.accept(@ruby_visitor))
        end
      end

      # Rewrite `class="foo <%= something %> bar"`
      def visit_attribute(node)
        clone = super
        return clone unless node.key.value == "class"
        return clone unless node.value.is_a?(SyntaxTree::ERB::HtmlString)

        contents =
          clone.value.contents.reject do |content|
            content.is_a?(SyntaxTree::ERB::Token) && content.type == :whitespace
          end

        clone.value.instance_variable_set(
          :@contents,
          contents.map.with_index do |content, index|
            next content unless content.is_a?(SyntaxTree::ERB::Token)

            # It's already a clone, so it's OK to mutate it
            new_value = @sorter.sort(content.value.split).join(" ")
            new_value = " #{new_value}" if index.positive? && erb_node?(contents[index - 1])
            new_value = "#{new_value} " if index < contents.size - 1 &&
              erb_node?(contents[index + 1])
            content.instance_variable_set(:@value, new_value)
            content
          end
        )

        clone
      end

      private

      def erb_node?(node)
        node.is_a?(SyntaxTree::ERB::ErbNode)
      end
    end
  end
end
