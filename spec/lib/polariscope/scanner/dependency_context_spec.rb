# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::DependencyContext do
  subject(:dependency_context) { described_class.new(**opts) }

  describe '#no_dependencies?' do
    subject(:result) { dependency_context.no_dependencies? }

    context 'when gemfile content is nil' do
      let(:opts) { { gemfile_lock_content: 'content' } }

      it { is_expected.to be(true) }
    end

    context 'when gemfile content is empty' do
      let(:opts) { { gemfile_content: '', gemfile_lock_content: 'content' } }

      it { is_expected.to be(true) }
    end

    context 'when gemfile lock content is nil' do
      let(:opts) { { gemfile_content: 'content' } }

      it { is_expected.to be(true) }
    end

    context 'when gemfile lock content is empty' do
      let(:opts) { { gemfile_lock_content: '', gemfile_content: 'content' } }

      it { is_expected.to be(true) }
    end

    context 'when there are no dependencies' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_no_dependencies'),
          gemfile_lock_ontent: File.read('spec/files/gemfile.lock_with_no_dependencies')
        }
      end

      it { is_expected.to be(true) }
    end

    context 'when there are dependencies' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_dependencies'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_dependencies')
        }
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#dependencies' do
    context "when gemfile lock doesn't have a ruby version" do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_dependencies'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_dependencies')
        }
      end

      it 'returns dependencies without ruby' do
        expect(dependency_context.dependencies.map(&:class).uniq).to contain_exactly(Bundler::Dependency)
        expect(dependency_context.dependencies.map(&:name)).to contain_exactly('rails', 'shrine', 'sidekiq',
                                                                               'rspec-rails')
      end
    end

    context 'when gemfile lock has a ruby version' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version')
        }
      end

      it 'returns dependencies with ruby' do
        expect(dependency_context.dependencies.map(&:class).uniq).to contain_exactly(Bundler::Dependency)
        expect(dependency_context.dependencies.map(&:name)).to contain_exactly('rails', 'shrine', 'sidekiq',
                                                                               'rspec-rails', 'ruby')
      end
    end
  end

  describe '#dependency_versions' do
    context "when gemfile lock doesn't have a ruby version" do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_dependencies'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_dependencies')
        }
      end

      let(:dependency) { Bundler::Dependency.new('rails', false) }

      before do
        gem_tuples = [
          [
            Gem::NameTuple.new('rails', Gem::Version.new('5.0.0')),
            anything
          ],
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

      it 'returns current version and all dependency versions' do
        current_version, all_versions = dependency_context.dependency_versions(dependency)

        expect(current_version).to eq(Gem::Version.new('7.0.0'))
        expect(all_versions).to contain_exactly(Gem::Version.new('5.0.0'), Gem::Version.new('6.0.0'),
                                                Gem::Version.new('7.0.0'))
      end
    end

    context 'when gemfile lock has a ruby version' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version')
        }
      end

      let(:dependency) { Bundler::Dependency.new('ruby', false) }

      before do
        available_versions = Set[Gem::Version.new('2.5.0'), Gem::Version.new('2.6.0')]

        allow(Gem::SpecFetcher.fetcher).to receive(:detect).with(:released).and_return([])
        allow(Polariscope::Scanner::RubyVersions).to receive(:available_versions).and_return(available_versions)
      end

      it 'returns current version and all dependency versions' do
        current_version, all_versions = dependency_context.dependency_versions(dependency)

        expect(current_version).to eq(Gem::Version.new('2.5.0'))
        expect(all_versions).to contain_exactly(Gem::Version.new('2.5.0'), Gem::Version.new('2.6.0'))
      end
    end
  end

  describe '#advisories' do
    context 'when there are no ignored advisories' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version')
        }
      end

      it 'returns advisories' do
        expect(dependency_context.advisories.map(&:class).uniq).to contain_exactly(Bundler::Audit::Advisory)
      end

      # https://nvd.nist.gov/vuln/detail/CVE-2024-47889
      it 'returns dependency advisories' do
        expect(dependency_context.advisories.map(&:id)).to include('CVE-2024-47889')
      end

      # https://nvd.nist.gov/vuln/detail/CVE-2024-27282
      it 'returns Ruby advisories' do
        expect(dependency_context.advisories.map(&:id)).to include('CVE-2024-27282')
      end
    end

    context 'when there are ignored advisories' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version'),
          bundler_audit_config_content: 'ignore: [CVE-2024-27282]'
        }
      end

      it "doesn't include those advisories" do
        expect(dependency_context.advisories.map(&:id)).not_to include('CVE-2024-27282')
      end
    end

    context 'when bundler audit config content is invalid' do
      let(:opts) do
        {
          gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
          gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version'),
          bundler_audit_config_content: '%invalid%'
        }
      end

      it "doesn't fail" do
        expect(dependency_context.advisories).not_to be_empty
      end
    end
  end
end
