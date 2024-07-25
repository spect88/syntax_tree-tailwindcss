# frozen_string_literal: true

require "test_helper"

class RubyTest < Minitest::Test
  def setup
    SyntaxTree::Tailwindcss.custom_order = %w[mt-8 mb-4 text-2xl font-bold]
  end

  def teardown
    SyntaxTree::Tailwindcss.custom_order = nil
  end

  def test_class_keyword
    source = <<~SOURCE
      module SomeHelper
        def h3(text)
          tag.h3(text, class: 'text-2xl  font-bold mb-4')
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def h3(text)
          tag.h3(text, class: "mb-4 text-2xl font-bold")
        end
      end
    FORMATTED
  end

  def test_class_symbol_keyed_hash
    source = <<~SOURCE
      module SomeHelper
        def h3(text)
          tag.h3(text, :class => 'text-2xl  font-bold mb-4')
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def h3(text)
          tag.h3(text, class: "mb-4 text-2xl font-bold")
        end
      end
    FORMATTED
  end

  def test_class_names
    source = <<~SOURCE
      module SomeHelper
        def foo_classes
          class_names('text-2xl  mt-8', something_else, 'font-bold mb-4')
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def foo_classes
          class_names("mt-8 text-2xl", something_else, "mb-4 font-bold")
        end
      end
    FORMATTED
  end

  def test_class_names_one_class_per_string
    source = <<~SOURCE
      module SomeHelper
        def foo_classes
          class_names('text-2xl', 'mt-8', something_else, 'font-bold', 'mb-4')
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def foo_classes
          class_names("mt-8", "text-2xl", something_else, "mb-4", "font-bold")
        end
      end
    FORMATTED
  end

  def test_class_names_without_parens
    source = <<~SOURCE
      module SomeHelper
        def foo_classes
          class_names 'text-2xl  mt-8', something_else, 'font-bold mb-4'
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def foo_classes
          class_names "mt-8 text-2xl", something_else, "mb-4 font-bold"
        end
      end
    FORMATTED
  end

  def test_class_with_embedded_variables
    source = <<~SOURCE
      module SomeHelper
        def h3(text)
          tag.h3(text, class: "text-2xl \#{something_else} font-bold mb-4")
        end
      end
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree.format(source))
      module SomeHelper
        def h3(text)
          tag.h3(text, class: "text-2xl \#{something_else} mb-4 font-bold")
        end
      end
    FORMATTED
  end
end
