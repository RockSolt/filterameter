# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  it 'flags invalid declarations' do
    declarations = described_class.declarations_validator
    expect(declarations).not_to be_valid
  end

  it 'provides clear explanations for invalid declarations' do
    declarations = described_class.declarations_validator
    declarations.valid?

    expect(declarations.errors.join("\n")).to eq <<~ERROR.chomp

      Invalid filter for 'inline_with_arg':
        Activity scope 'inline_with_arg' needs to be written as a class method, not as an inline scope

      Invalid filter for 'not_a_scope':
        Activity class method 'not_a_scope' is not a scope

      Invalid filter for 'not_a_conditional_scope':
        Activity class method 'not_a_conditional_scope' is not a scope

      Invalid filter for 'scope_with_multiple_args':
        Filter factory failed to build scope_with_multiple_args: Scopes for filters can only have either zero (conditional scopes) or one argument

      Invalid sort for 'updated_at_typo':
        Attribute 'updated_at_typo' does not exist on Activity

      Invalid sort for 'sort_scope_with_no_args':
        Activity scope 'sort_scope_with_no_args' must take exactly one argument to sort by
    ERROR
  end
end
