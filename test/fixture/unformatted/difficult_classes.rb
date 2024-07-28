# frozen_string_literal: true

module DifficultClasses
  def dynamic(&block)
    tag(
      :div,
      class:
        "text-[#50d71e] !p-2 text-sm/[17px] rounded-[12px] group-[:nth-of-type(3)_&]:block *:py-0.5 w-[calc(100%+2rem)]",
      &block
    )
  end
end
