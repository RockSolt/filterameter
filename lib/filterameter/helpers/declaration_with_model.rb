# frozen_string_literal: true

module Filterameter
  module Helpers
    # # Declaration with Model
    #
    # Class DeclarationWithModel inspects the declaration under the context of the model. This enables
    # predicate methods as well as drilling through associations.
    class DeclarationWithModel
      def initialize(model, declaration)
        @model = model
        @declaration = declaration
      end

      def scope?
        model = @declaration.nested? ? model_from_association : @model

        model.respond_to?(@declaration.name) &&
          # checking dangerous_class_method? excludes any names that cannot be scope names, such as "name"
          !model.dangerous_class_method?(@declaration.name)
      end

      def any_collections?
        @declaration.association.reduce(@model) do |related_model, name|
          association = related_model.reflect_on_association(name)
          return true if association.collection?

          association.klass
        end

        false
      end

      def model_from_association
        @declaration.association.flatten.reduce(@model) do |memo, name|
          association = memo.reflect_on_association(name)
          raise_invalid_association if association.nil?

          association.klass
        end
      end

      private

      def raise_invalid_association
        raise Filterameter::Exceptions::InvalidAssociationDeclarationError.new(@declaration.name,
                                                                               @model.name,
                                                                               @declaration.association)
      end
    end
  end
end
