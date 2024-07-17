# frozen_string_literal: true

module Filterameter
  module Filters
    # = Attribute Validator
    #
    # Module AttributeValidator validates that the attribute exists on the model.
    module AttributeValidator
      private

      def validate(model)
        return if model.attribute_method? @attribute_name

        @errors << "Attribute '#{@attribute_name}' does not exist on #{model.name}"
      end
    end
  end
end
