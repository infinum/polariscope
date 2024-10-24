# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemHealthScore do
  subject(:gem_health_score) { described_class.new(dependency_context, calculation_context, dependency) }

  let(:dependency_context) do
    Polariscope::Scanner::DependencyContext.new(
      gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
      gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version')
    )
  end
  let(:calculation_context) { Polariscope::Scanner::CalculationContext.new }
  let(:dependency) { Bundler::Dependency.new('rails', false) }

  describe '#health_score' do
    context 'when up to date' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('6.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns 1.0' do
        expect(gem_health_score.health_score).to eq(1.0)
      end
    end

    context 'when major version is outdated' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.1.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('8.0.0')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns a health score' do
        expect(gem_health_score.health_score.round(3)).to eq(0.643)
      end
    end

    context 'when minor version is outdated' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.1')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.1.0')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns a health score' do
        expect(gem_health_score.health_score.round(3)).to eq(0.843)
      end
    end

    context 'when patch version is outdated' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.1')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns a health score' do
        expect(gem_health_score.health_score.round(3)).to eq(0.948)
      end
    end
  end

  describe '#major_version_penalty' do
    context 'when major version is outdated' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('8.0.0')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns a penalty' do
        expect(gem_health_score.major_version_penalty).to eq(1)
      end
    end

    context 'when major version is up-to-date' do
      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.0.0')),
            anything
          ],
          [
            Gem::NameTuple.new('rails', Gem::Version.new('7.1.0')),
            anything
          ]
        ]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return(gem_tuples)
      end

      it 'returns zero' do
        expect(gem_health_score.major_version_penalty).to eq(0)
      end
    end
  end
end
