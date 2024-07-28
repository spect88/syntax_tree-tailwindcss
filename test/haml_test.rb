# frozen_string_literal: true

require "test_helper"

class HamlTest < Minitest::Test
  def setup
    SyntaxTree::Tailwindcss.custom_order = %w[mt-8 mb-4 text-2xl font-bold]
  end

  def teardown
    SyntaxTree::Tailwindcss.custom_order = nil
  end

  def test_haml_classes
    source = <<~SOURCE
      .text-2xl.font-bold.mb-4
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      .mb-4.text-2xl.font-bold
    FORMATTED
  end

  def test_html_classes
    source = <<~SOURCE
      %div(class='text-2xl  font-bold mb-4')
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      .mb-4.text-2xl.font-bold
    FORMATTED
  end

  def test_html_classes_with_embedded_ruby
    source = <<~SOURCE
      %div(class="text-2xl mt-8 \#{something} font-bold mb-4")
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      (class="mt-8 text-2xl \#{something} mb-4 font-bold")
    FORMATTED
  end

  def test_hash_classes_string
    source = <<~SOURCE
      %div{class: "text-2xl mt-8 \#{something} font-bold mb-4"}
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      %div{class: "mt-8 text-2xl \#{something} mb-4 font-bold"}
    FORMATTED
  end

  def test_hash_classes_array
    source = <<~SOURCE
      %div{class: ['text-2xl', 'mt-8', something, 'font-bold', 'mb-4']}
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      %div{class: ["mt-8", "text-2xl", something, "mb-4", "font-bold"]}
    FORMATTED
  end

  def test_ruby
    skip("The Ruby code doesn't seem to be formatted currently")
    source = <<~SOURCE
      = tag.h3 class: 'text-2xl  font-bold mb-4'
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::Haml.format(source))
      = tag.h3 class: "mb-4 text-2xl font-bold"
    FORMATTED
  end
end
