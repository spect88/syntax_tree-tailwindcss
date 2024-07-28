# frozen_string_literal: true

# Modified version of https://github.com/Daniel-N-Huss/tailwind_form_builder_example/blob/main/app/lib/form_builders/tailwind_form_builder.rb

module FormBuilders
  class TailwindFormBuilder < ActionView::Helpers::FormBuilder
    class_attribute :text_field_helpers,
                    default:
                      field_helpers -
                        %i[label check_box radio_button fields_for fields hidden_field file_field]
    #  leans on the FormBuilder class_attribute `field_helpers`
    #  you'll want to add a method for each of the specific helpers listed here if you want to style them

    text_field_helpers.each { |field_method| class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1 }
          def #{field_method}(method, options = {})
            if options.delete(:tailwindified)
              super
            else
              text_like_field(#{field_method.inspect}, method, options)
            end
          end
      RUBY_EVAL

    def submit(value = nil, options = {})
      custom_opts, opts = partition_custom_opts(options)

      classes =
        class_names(
          "shadow bg-yellow-800 focus:shadow-outline focus:outline-none text-white font-bold py-2 px-4 rounded hover:bg-yellow-700",
          border_color_classes(nil),
          custom_opts[:class]
        )

      super(value, { class: classes }.merge(opts))
    end

    def select(method, choices = nil, options = {}, html_options = {}, &block)
      custom_opts, opts = partition_custom_opts(options)

      classes =
        class_names(
          "block bg-gray-200 focus:bg-white text-gray-700 py-2 rounded leading-tight focus:outline-none px-4",
          border_color_classes(method),
          custom_opts[:class]
        )

      labels = labels(method, custom_opts[:label], options)
      field = super(method, choices, opts, html_options.merge({ class: classes }), &block)

      labels + field
    end

    private

    def text_like_field(field_method, object_method, options = {})
      custom_opts, opts = partition_custom_opts(options)

      classes =
        class_names(
          "bg-gray-200 rounded py-2 px-4 text-gray-700 leading-tight focus:outline-none focus:bg-white",
          border_color_classes(object_method),
          custom_opts[:class]
        )

      field =
        send(
          field_method,
          object_method,
          { class: classes, title: errors_for(object_method)&.join(" ") }.compact
            .merge(opts)
            .merge({ tailwindified: true })
        )

      labels = labels(object_method, custom_opts[:label], options)

      labels + field
    end

    def labels(object_method, label_options, field_options)
      label = tailwind_label(object_method, label_options, field_options)
      error_label = error_label(object_method, field_options)

      @template.content_tag("div", label + error_label, { class: "flex-col items-start flex" })
    end

    def tailwind_label(object_method, label_options, field_options)
      text, label_opts =
        (label_options.present? ? [label_options[:text], label_options.except(:text)] : [nil, {}])

      label_classes =
        label_opts[:class] ||
          class_names("block text-gray-500 font-bold md:text-right mb-1 md:mb-0 pr-4")
      label_classes =
        class_names(label_classes, "text-yellow-800 dark:text-yellow-400") if field_options[
        :disabled
      ]
      label(object_method, text, { class: label_classes }.merge(label_opts.except(:class)))
    end

    def error_label(object_method, options)
      if errors_for(object_method).present?
        error_message = @object.errors[object_method].collect(&:titleize).join(", ")
        tailwind_label(
          object_method,
          { text: error_message, class: " font-bold text-red-500" },
          options
        )
      end
    end

    def border_color_classes(object_method)
      if errors_for(object_method).present?
        class_names("border-2 border-red-400 focus:border-rose-200")
      else
        class_names("border focus:border-yellow-700 border-gray-300")
      end
    end

    CUSTOM_OPTS = %i[label class].freeze
    def partition_custom_opts(opts)
      opts.partition { |k, _v| CUSTOM_OPTS.include?(k) }.map(&:to_h)
    end

    def errors_for(object_method)
      return unless @object.present? && object_method.present?

      @object.errors[object_method]
    end
  end
end
