# frozen_string_literal: true

module DifficultClasses
  def dynamic(&block)
    tag(
      :div,
      class:
        "w-[calc(100%+2rem)] rounded-[12px] !p-2 text-sm/[17px] text-[#50d71e] *:py-0.5 group-[:nth-of-type(3)_&]:block",
      &block
    )
  end
end
