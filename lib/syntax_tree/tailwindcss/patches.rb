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

      module Haml
        def parse(source)
          node = ::Haml::Parser.new({}).call(source)
          node.accept(Tailwindcss.haml_mutation_visitor)
        end
      end

      module HamlFormat
        def parse_attributes_hash(source, node, ...)
          modified_node =
            node.accept(Tailwindcss.haml_mutation_visitor.haml_attributes_mutation_visitor)
          super(source, modified_node, ...)
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

  # This should only be done if Haml plugin is already loaded
  if const_defined?("Haml")
    module Haml
      class << self
        prepend Tailwindcss::Patches::Haml
      end
      Format.prepend(Tailwindcss::Patches::HamlFormat)
    end
  end
end
