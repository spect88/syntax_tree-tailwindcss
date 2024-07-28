# frozen_string_literal: true

require "syntax_tree/haml/mutation_visitor"

module SyntaxTree
  module Tailwindcss
    class HamlMutationVisitor < SyntaxTree::Haml::MutationVisitor
      def initialize(sorter)
        super()
        @sorter = sorter
        @ruby_visitor = SyntaxTree::Tailwindcss::RubyMutationVisitor.new(@sorter)
      end

      def visit_tag(node)
        super.tap do |clone|
          next unless node.value

          # Rewrite `.foo.bar`
          if node.value[:attributes].key?("class")
            clone.value[:attributes]["class"] = @sorter.sort(
              node.value[:attributes]["class"].split
            ).join(" ")
          end

          # Rewrite `(class="foo #{something} bar")`
          if node.value[:dynamic_attributes].new&.include?('"class"')
            clone.value[:dynamic_attributes] = node.value[:dynamic_attributes].dup.tap do |attrs|
              attrs.new = rewrite_html_attributes(attrs.new)
            end
          end
        end
      end

      # Rewrites `(class="foo #{something} bar")`
      def rewrite_html_attributes(string)
        new_string = string.dup

        pattern = <<~PATTERN
          Assoc[
            key: StringLiteral[parts: [TStringContent[value: "class"]]],
            value: StringLiteral
          ]
        PATTERN

        SyntaxTree.search(string, pattern) do |assoc_node|
          location = assoc_node.value.location
          rewritten = @ruby_visitor.rewrite_string_literal(assoc_node.value)

          formatter = SyntaxTree::Formatter.new(string, [], 10_000)
          rewritten.format(formatter)
          formatter.flush(0)
          formatted = formatter.output.join

          new_string[location.start_char...location.end_char] = formatted
        end

        new_string
      end

      def haml_attributes_mutation_visitor
        @haml_attributes_mutation_visitor ||=
          SyntaxTree.mutation do |visitor|
            # Rewrite `class: ["foo", "bar"]` and `class: "foo bar"`
            visitor.mutate(<<~PATTERN) do |node|
                Assoc[
                  key: Label[value: 'class:'] | SymbolLiteral[value: Kw[value: 'class']],
                  value: ArrayLiteral[contents: Args] | StringLiteral
                ]
              PATTERN
              case node.value
              when ArrayLiteral
                args = @ruby_visitor.rewrite_args(node.value.contents)
                node.copy(value: node.value.copy(contents: args))
              when StringLiteral
                new_value = @ruby_visitor.rewrite_string_literal(node.value)
                node.copy(value: new_value)
              else
                node
              end
            end
          end
      end
    end
  end
end
