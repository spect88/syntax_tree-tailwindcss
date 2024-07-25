# frozen_string_literal: true

require "test_helper"

class SorterTest < Minitest::Test
  def test_parse_complicated_css
    input = <<~CSS.gsub("\n", "")
      /* .commented-out{padding:.125rem} */
      @media(min-width: 120px){
      .dynamic-\\[156px\\]:first-child input,
      .after-comma{font-size: .9rem}
      }
      .dark\\:bg-\\[\\#abcdef\\]:is(.dark *){background-color:#abcdef}
      .-mt-2{margin-top: 2px}
      .\\!something:after{display:block;content:'foo'}
    CSS
    output = SyntaxTree::Tailwindcss::Sorter.parse_tailwind_output(input)
    assert_equal(%w[dynamic-[156px] after-comma dark:bg-[#abcdef] dark -mt-2 !something], output)
  end

  def test_sort_simple
    sorter = SyntaxTree::Tailwindcss::Sorter.new(%w[container block p-2 py-5 mt-2])
    assert_equal(%w[container p-2 py-5], sorter.sort(%w[py-5 container p-2]))
  end

  def test_sort_duplicate_classes
    sorter = SyntaxTree::Tailwindcss::Sorter.new(%w[container block p-2 py-5 mt-2])
    assert_equal(%w[container p-2 py-5], sorter.sort(%w[p-2 container py-5 p-2]))
  end

  def test_sort_unknown_classes
    sorter = SyntaxTree::Tailwindcss::Sorter.new(%w[container block p-2 py-5 mt-2])
    # Non-tailwind classes are moved to the front, but otherwise keep existing order
    assert_equal(%w[custom-b custom-a p-2], sorter.sort(%w[p-2 custom-b custom-a]))
  end
end
