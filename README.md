# SyntaxTree plugin: tailwindcss

SyntaxTree can be used to format:

- `.rb` files that render HTML, e.g. Rails helpers
- `.haml` files (using the [haml](https://github.com/ruby-syntax-tree/syntax_tree-haml)
  plugin)
- `.html.erb` files (using the [erb](https://github.com/davidwessman/syntax_tree-erb)
  plugin)

All of these can contain TailwindCSS classes and this plugin will help you keep
them in order, just like
[the official prettier plugin](https://github.com/tailwindlabs/prettier-plugin-tailwindcss)
would.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add syntax_tree-tailwindcss

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install syntax_tree-tailwindcss

## Usage

Example:

    $ stree write --plugins=erb,tailwindcss app/helpers/**/*.rb app/views/**/*.html.erb

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spect88/syntax_tree-tailwindcss.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
