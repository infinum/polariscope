# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemVersions do
  subject(:scanner) { described_class.new(dependencies, spec_type: :released) }

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
    before { allow(Polariscope::Scanner::RubyVersions).to receive(:available_versions) }

    context 'when ruby is not in dependencies' do
      let(:dependencies) { ['devise', 'rails'] }

      it 'returns distinct versions for given gem name' do
        expect(scanner.versions_for('devise').map(&:to_s)).to contain_exactly('4.6.2', '4.5.0')
      end

      it "doesn't fetch ruby versions" do
        scanner

        expect(Polariscope::Scanner::RubyVersions).not_to have_received(:available_versions)
      end
    end

    context 'when ruby is in dependencies' do
      let(:dependencies) { ['devise', 'ruby', 'rails'] }

      it 'fetches ruby versions' do
        scanner

        expect(Polariscope::Scanner::RubyVersions).to have_received(:available_versions)
      end
    end
  end
end
