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

      module ERB
        def parse(source)
          node = ::SyntaxTree::ERB::Parser.new(source).parse
          node.accept(Tailwindcss.erb_mutation_visitor)
        end
      end
    end
  end

  class << self
    prepend Tailwindcss::Patches::SyntaxTree
  end

  # This should only be done if ERB plugin is already loaded
  if const_defined?("ERB")
    module ERB
      class << self
        prepend Tailwindcss::Patches::ERB
      end
    end
  end
end
