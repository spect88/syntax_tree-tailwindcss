# frozen_string_literal: true

require "test_helper"

class ErbTest < Minitest::Test
  def setup
    SyntaxTree::Tailwindcss.custom_order = %w[mt-8 mb-4 text-2xl font-bold]
  end

  def teardown
    SyntaxTree::Tailwindcss.custom_order = nil
  end

  def test_html
    source = <<~SOURCE
      <div class="text-2xl  font-bold mb-4"></div>
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::ERB.format(source))
      <div class="mb-4 text-2xl font-bold"></div>
    FORMATTED
  end

  def test_ruby_tag
    source = <<~SOURCE
      <div><%= tag.span class: 'text-2xl  font-bold mb-4' %></div>
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::ERB.format(source))
      <div><%= tag.span class: "mb-4 text-2xl font-bold" %></div>
    FORMATTED
  end

  def test_erb_inside_class_attribute
    source = <<~SOURCE
      <div class="
          text-2xl
          mt-8
          <%= some_class %>
          font-bold
          mb-4
        "
      ></div>
    SOURCE
    assert_equal(<<~FORMATTED, SyntaxTree::ERB.format(source))
      <div class="mt-8 text-2xl <%= some_class %> mb-4 font-bold"></div>
    FORMATTED
  end
end
