# frozen_string_literal: true

module SyntaxTree
  module Tailwindcss
    class Sorter
      def initialize(classes_in_order)
        @classes_order = classes_in_order.to_enum.with_index.to_h
      end

      def sort(classes)
        classes.uniq.sort_by { |cls| @classes_order[cls] || -1 }
      end

      def sort_order(cls)
        @classes_order[cls] || -1
      end

      class << self
        def load_cached
          return new(SyntaxTree::Tailwindcss.custom_order) if SyntaxTree::Tailwindcss.custom_order

          mtime = File.mtime(tailwind_output_path)
          return @cached_sorter if @cached_mtime == mtime

          @cached_sorter = load!
          @cached_mtime = mtime
          @cached_sorter
        rescue Errno::ENOENT
          warn do
            "Couldn't find TailwindCSS output (#{tailwind_output_path}). Classes won't be sorted."
          end
          new([])
        end

        def load!
          tailwind_output = File.read(tailwind_output_path)
          classes = parse_tailwind_output(tailwind_output)
          new(classes)
        end

        def tailwind_output_path
          if SyntaxTree::Tailwindcss.output_path
            SyntaxTree::Tailwindcss.output_path
          elsif ENV["TAILWIND_OUTPUT_PATH"]
            ENV["TAILWIND_OUTPUT_PATH"]
          else
            "app/assets/builds/application.css"
          end
        end

        def parse_tailwind_output(output)
          # We could use a real CSS parser, but that'd be slow and we only need to know valid classes
          output
            .gsub(%r{/\*.+?\*/}, "")
            .gsub(/\\(.)/) { "-ESCAPED-#{Regexp.last_match[1].ord}-" }
            .scan(/(?<=\.)[^0-9][^. {:>),\[]*/)
            .uniq
            .join(" ")
            .gsub(/-ESCAPED-(\d+)-/) { Regexp.last_match[1].to_i.chr(Encoding::UTF_8) }
            .split
        end
      end
    end
  end
end
