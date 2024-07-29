# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController do
  let(:error_messages) do
    <<~ERROR.chomp

      Invalid filter for 'inline_with_arg':
        #{Filterameter::DeclarationErrors::CannotBeInlineScopeError.new('Activity', :inline_with_arg)}

      Invalid filter for 'not_a_scope':
        #{Filterameter::DeclarationErrors::NotAScopeError.new('Activity', :not_a_scope)}

      Invalid filter for 'not_a_conditional_scope':
        #{Filterameter::DeclarationErrors::NotAScopeError.new('Activity', :not_a_conditional_scope)}

      Invalid filter for 'scope_with_multiple_args':
        #{Filterameter::DeclarationErrors::FilterScopeArgumentError.new('Activity', :scope_with_multiple_args)}

      Invalid sort for 'updated_at_typo':
        #{Filterameter::DeclarationErrors::NoSuchAttributeError.new('Activity', :updated_at_typo)}

      Invalid sort for 'sort_scope_with_no_args':
        #{Filterameter::DeclarationErrors::SortScopeRequiresOneArgumentError.new('Activity', :sort_scope_with_no_args)}
    ERROR
  end

  it 'flags invalid declarations' do
    declarations = described_class.declarations_validator
    expect(declarations).not_to be_valid
  end

  it 'provides clear explanations for invalid declarations' do
    declarations = described_class.declarations_validator
    declarations.valid?

    expect(declarations.errors).to eq error_messages
  end
end
