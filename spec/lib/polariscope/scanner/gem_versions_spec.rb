# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemVersions do
  subject(:scanner) { described_class.new(['devise', 'rails'], spec_type: :released) }

  before do
    gem_tuples = [
      [
        Gem::NameTuple.new('devise', Gem::Version.new('4.6.2')),
        anything
      ],
      [
        Gem::NameTuple.new('devise', Gem::Version.new('4.5.0')),
        anything
      ],
      [
        Gem::NameTuple.new('devise', Gem::Version.new('4.5.0')),
        anything
      ],
      [
        Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
        anything
      ]
    ]

    allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
  end

  describe '#versions_for' do
    it 'returns only distinct versions for given gem name' do
      expect(scanner.versions_for('devise').map(&:to_s)).to contain_exactly('4.6.2', '4.5.0')
    end
  end
end
