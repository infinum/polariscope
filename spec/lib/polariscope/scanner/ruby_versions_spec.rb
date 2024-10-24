# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::RubyVersions do
  subject(:ruby_versions) { described_class }

  describe '.available_versions' do
    it 'returns published ruby versions' do
      result = ruby_versions.available_versions

      expect(result).to be_a(Set)
      expect(result.map(&:class).uniq).to contain_exactly(Gem::Version)
      expect(result.none?(&:prerelease?)).to be(true)
      expect(result.min).to eq(Gem::Version.new('1.2.1'))
    end

    context 'when an open timeout error is raised' do
      before { allow(URI).to receive(:parse).and_raise(Net::OpenTimeout) }

      it 'returns an empty set' do
        expect(ruby_versions.available_versions).to eq(Set.new)
      end
    end

    context 'when a read timeout error is raised' do
      before { allow(URI).to receive(:parse).and_raise(Net::ReadTimeout) }

      it 'returns an empty set' do
        expect(ruby_versions.available_versions).to eq(Set.new)
      end
    end
  end
end
