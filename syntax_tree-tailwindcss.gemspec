# frozen_string_literal: true

require_relative "lib/syntax_tree/tailwindcss/version"

Gem::Specification.new do |spec|
  spec.name = "syntax_tree-tailwindcss"
  spec.version = SyntaxTree::Tailwindcss::VERSION
  spec.authors = ["Tomasz Szczęśniak-Szlagowski"]
  spec.email = ["spect88@gmail.com"]

  spec.summary = "A Syntax Tree plugin for sorting TailwindCSS classes"
  spec.description = "It sorts Tailwind classes in your helpers and ERB files and sorts them"
  spec.homepage = "https://github.com/spect88/syntax_tree-tailwindcss"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files =
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls
        .readlines("\x0", chomp: true)
        .reject do |f|
          (f == gemspec) ||
            f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
        end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "syntax_tree", "~> 6.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
