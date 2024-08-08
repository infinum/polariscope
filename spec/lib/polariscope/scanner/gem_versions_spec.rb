# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemVersions do
  subject(:scanner) { described_class.new(['devise', 'rails'], spec_type: :released) }

  let(:fetcher) { instance_double(Gem::SpecFetcher) }
  let(:gem_tuples) do
    [
      [
        instance_double(Gem::NameTuple, name: 'devise', version: instance_double(Gem::Version, to_s: '4.6.2')),
        anything
      ],
      [
        instance_double(Gem::NameTuple, name: 'devise', version: instance_double(Gem::Version, to_s: '4.5.0')),
        anything
      ],
      [
        instance_double(Gem::NameTuple, name: 'rails', version: instance_double(Gem::Version, to_s: '7.0.0')),
        anything
      ]
    ]
  end

  before do
    allow(Gem::SpecFetcher).to receive(:fetcher).and_return(fetcher)
    allow(fetcher).to receive(:detect).and_return(gem_tuples)
  end

  describe '#versions_for' do
    it 'returns only versions for given gem name' do
      expect(scanner.versions_for('devise').map(&:to_s)).to eq(['4.6.2', '4.5.0'])
    end
  end
end
