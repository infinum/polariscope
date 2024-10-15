# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::RubyScanner do
  subject(:scanner) { described_class.new(lockfile_parser) }

  let(:lockfile_parser) { Bundler::LockfileParser.new(gemfile_lock_content) }

  describe '#version' do
    context 'when Gemfile.lock has Ruby version information' do
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_ruby_version') }

      it 'returns Ruby version' do
        expect(scanner.version).to eq(Gem::Version.new('3.0.0'))
      end
    end

    context "when Gemfile.lock doesn't have Ruby version information" do
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_no_dependencies') }

      it 'returns nil' do
        expect(scanner.version).to be_nil
      end
    end
  end

  describe '#vulnerable_advisories' do
    context 'when Gemfile.lock has Ruby version information' do
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_ruby_version') }

      it 'returns relevant advisories' do
        expect(scanner.vulnerable_advisories).not_to be_empty
        expect(scanner.vulnerable_advisories.map(&:class).uniq).to eq([Bundler::Audit::Advisory])
      end
    end

    context "when Gemfile.lock doesn't have Ruby version information" do
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_no_dependencies') }

      it 'returns an empty array' do
        expect(scanner.vulnerable_advisories).to eq([])
      end
    end
  end
end
