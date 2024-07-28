# frozen_string_literal: true

require_relative "tailwindcss/version"
require_relative "tailwindcss/patches"

module SyntaxTree
  module Tailwindcss
    autoload :Sorter, "syntax_tree/tailwindcss/sorter"
    autoload :RubyMutationVisitor, "syntax_tree/tailwindcss/ruby_mutation_visitor"
    autoload :ErbMutationVisitor, "syntax_tree/tailwindcss/erb_mutation_visitor"

    class << self
      attr_accessor :output_path, :custom_order

      def ruby_mutation_visitor
        sorter = Sorter.load_cached
        RubyMutationVisitor.new(sorter)
      end

      def erb_mutation_visitor
        sorter = Sorter.load_cached
        ErbMutationVisitor.new(sorter)
      end
    end
  end
end
