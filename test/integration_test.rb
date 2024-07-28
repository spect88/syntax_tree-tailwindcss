# frozen_string_literal: true

require "test_helper"
require "open3"

class IntegrationTest < Minitest::Test
  def test_difficult_classes_rb
    check_formatting("difficult_classes.rb")
  end

  def test_form_builder_rb
    check_formatting("form_builder.rb")
  end

  def test_login_form_html_erb
    check_formatting("login_form.html.erb")
  end

  def test_password_change_form_haml
    check_formatting("password_change_form.haml")
  end

  def test_score_rating_html_erb
    check_formatting("score_rating.html.erb")
  end

  def check_formatting(filename)
    env = { "RUBYLIB" => "lib", "TAILWIND_OUTPUT_PATH" => "test/fixture/tailwind.output.min.css" }
    stdout, =
      Open3.capture2(
        env,
        "stree",
        "format",
        "--plugins=erb,haml,tailwindcss",
        "--print-width=100",
        "test/fixture/unformatted/#{filename}"
      )
    expected = File.read("test/fixture/formatted/#{filename}")
    # When the output is better than what we expected:
    # File.write("test/fixture/formatted/#{filename}", stdout)
    assert_equal(expected, stdout)
  end
end
