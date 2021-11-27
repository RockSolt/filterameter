# frozen_string_literal: true

require 'filterameter/exceptions'

RSpec.describe Filterameter::Exceptions::CannotDetermineModelError do
  let(:error) { described_class.new('foo', 'foo/bar') }

  it '#message' do
    expect(error.message).to eq 'Cannot determine model name from controller name (foo => Foo) '\
                                'or path (foo/bar => Foo::Bar). Declare the model explicitly with filter_model.'
  end
end
