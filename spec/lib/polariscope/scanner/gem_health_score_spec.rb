# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemHealthScore do
  subject(:score) do
    described_class.new(
      all_versions: all_versions,
      current_version: current_version,
      severities: severities
    ).health_score
  end

  context 'when up to date' do
    let(:all_versions) { [Gem::Version.new('1.0.0'), Gem::Version.new('1.0.1'), Gem::Version.new('1.1.0')] }
    let(:current_version) { Gem::Version.new('1.1.0') }
    let(:severities) { [] }

    it 'returns 100' do
      expect(score).to eq(100)
    end
  end

  context 'when outdated' do
    let(:all_versions) do
      [Gem::Version.new('1.0.0'), Gem::Version.new('1.0.1'), Gem::Version.new('1.1.0'),
       Gem::Version.new('2.0.0'), Gem::Version.new('2.0.1'), Gem::Version.new('2.1.0')]
    end
    let(:current_version) { Gem::Version.new('1.1.0') }
    let(:severities) { [1.7, 1.5, 1.01] }

    it 'returns a score less than 100' do
      expect(score.round(2)).to eq(63.03)
    end
  end
end
