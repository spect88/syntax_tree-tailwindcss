# frozen_string_literal: true

module SyntaxTree
  module Tailwindcss
    module Patches
      module SyntaxTree
        def format_node(source, node, ...)
          modified_node = node.accept(Tailwindcss.ruby_mutation_visitor)
          super(source, modified_node, ...)
        end
      end
    end
  end

  class << self
    prepend Tailwindcss::Patches::SyntaxTree
  end
end
