# frozen_string_literal: true

module SyntaxTree
  module Tailwindcss
    class RubyMutationVisitor < SyntaxTree::MutationVisitor
      def initialize(sorter)
        super()
        @sorter = sorter

        # Rewrite `class: "foo bar"` and `:class => "foo bar"`
        mutate(<<~PATTERN) { |node| node.copy(value: rewrite_string_literal(node.value)) }
            Assoc[
              key: Label[value: 'class:'] | SymbolLiteral[value: Kw[value: 'class']],
              value: StringLiteral
            ]
          PATTERN

        # Rewrite `class_names("foo bar", "lorem ipsum")`
        mutate("CallNode[message: Ident[value: 'class_names']]") do |node|
          next node unless node.arguments.is_a?(ArgParen)
          next node unless node.arguments.arguments.is_a?(Args)

          args = node.arguments.arguments
          node.copy(arguments: node.arguments.copy(arguments: rewrite_args(args)))
        end

        # Rewrite `class_names "foo bar", "lorem ipsum"`
        mutate("Command[message: Ident[value: 'class_names']]") do |node|
          next node unless node.arguments.is_a?(Args)

          node.copy(arguments: rewrite_args(node.arguments))
        end
      end

      def rewrite_string_literal(string_literal)
        return string_literal unless string_literal.is_a?(StringLiteral)

        string_parts =
          string_literal.parts.map do |string_part|
            next string_part unless string_part.is_a?(TStringContent)

            value = string_part.value
            new_value = @sorter.sort(value.split).join(" ")
            new_value = " #{new_value}" if value.match?(/\A\s/)
            new_value = "#{new_value} " if value.match?(/\s\z/)
            string_part.copy(value: new_value)
          end
        string_literal.copy(parts: string_parts)
      end

      def rewrite_args(args)
        return args unless args.is_a?(Args)

        # Rewrite each string literal separately, e.g. 'mb-4 text-2xl'
        rewritten_parts = args.parts.map { |part| rewrite_string_literal(part) }

        # Reorder subsequent single-class strings, e.g. 'mb-4', 'text-2xl'
        reordered_parts =
          rewritten_parts
            .slice_when { |a, b| single_class_string_literal?(a) ^ single_class_string_literal?(b) }
            .map do |segment|
              next segment if segment.size == 1 || !single_class_string_literal?(segment.first)

              segment
                .uniq { |node| node.parts.first.value }
                .sort_by { |node| @sorter.sort_order(node.parts.first.value) }
            end
            .flatten

        args.copy(parts: reordered_parts)
      end

      def single_class_string_literal?(string_literal)
        string_literal.is_a?(StringLiteral) && string_literal.parts.size == 1 &&
          string_literal.parts.first.is_a?(TStringContent) &&
          string_literal.parts.first.value.match?(/\A\S+\z/)
      end
    end
  end
end
