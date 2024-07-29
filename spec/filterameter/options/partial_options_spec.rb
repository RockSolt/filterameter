# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filterameter::Options::PartialOptions do
  shared_examples 'matches anywhere' do
    it { expect(options).to be_match_anywhere }
    it { expect(options).not_to be_match_from_start }
    it { expect(options).not_to be_match_dynamically }
  end

  shared_examples 'matches from start' do
    it { expect(options).not_to be_match_anywhere }
    it { expect(options).to be_match_from_start }
    it { expect(options).not_to be_match_dynamically }
  end

  shared_examples 'matches dynamically' do
    it { expect(options).not_to be_match_anywhere }
    it { expect(options).not_to be_match_from_start }
    it { expect(options).to be_match_dynamically }
  end

  shared_examples 'not case sensitive' do
    it { expect(options).not_to be_case_sensitive }
  end

  shared_examples 'case sensitive' do
    it { expect(options).to be_case_sensitive }
  end

  describe 'partial: true' do
    let(:options) { described_class.new(true) }

    it_behaves_like 'matches anywhere'
    it_behaves_like 'not case sensitive'
    it('#to_s') { expect(options.to_s).to eq 'true' }
  end

  describe 'partial: :anywhere' do
    let(:options) { described_class.new(:anywhere) }

    it_behaves_like 'matches anywhere'
    it_behaves_like 'not case sensitive'
    it('#to_s') { expect(options.to_s).to eq 'true' }
  end

  describe 'partial: :from_start' do
    let(:options) { described_class.new(:from_start) }

    it_behaves_like 'matches from start'
    it_behaves_like 'not case sensitive'
    it('#to_s') { expect(options.to_s).to eq ':from_start' }
  end

  describe 'partial: :dynamic' do
    let(:options) { described_class.new(:dynamic) }

    it_behaves_like 'matches dynamically'
    it_behaves_like 'not case sensitive'
    it('#to_s') { expect(options.to_s).to eq ':dynamic' }
  end

  describe "partial: 'anywhere' (as string)" do
    let(:options) { described_class.new('anywhere') }

    it_behaves_like 'matches anywhere'
    it_behaves_like 'not case sensitive'
  end

  describe 'partial: { match: :from_start }' do
    let(:options) { described_class.new(match: :from_start) }

    it_behaves_like 'matches from start'
    it_behaves_like 'not case sensitive'
    it('#to_s') { expect(options.to_s).to eq ':from_start' }
  end

  describe 'partial: { case_sensitive: true }' do
    let(:options) { described_class.new(case_sensitive: true) }

    it_behaves_like 'matches anywhere'
    it_behaves_like 'case sensitive'
    it('#to_s') { expect(options.to_s).to eq '{ case_sensitive: true }' }
  end

  describe 'partial: { match: :from_start, case_sensitive: true }' do
    let(:options) { described_class.new(match: :from_start, case_sensitive: true) }

    it_behaves_like 'matches from start'
    it_behaves_like 'case sensitive'
    it('#to_s') { expect(options.to_s).to eq '{ match: :from_start, case_sensitive: true }' }
  end
end
