# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::RubyScanner do
  subject(:scanner) { described_class.new(bundler_ruby_version) }

  describe '#version' do
    context 'when bundler ruby version exists' do
      let(:bundler_ruby_version) { Bundler::RubyVersion.from_string('ruby 3.0.0') }

      it 'returns Ruby version' do
        expect(scanner.version).to eq(Gem::Version.new('3.0.0'))
      end
    end

    context "when bundler ruby version doesn't" do
      let(:bundler_ruby_version) { nil }

      it 'returns nil' do
        expect(scanner.version).to be_nil
      end
    end
  end

  describe '#vulnerable_advisories' do
    context 'when bundler ruby version exists' do
      let(:bundler_ruby_version) { Bundler::RubyVersion.from_string('ruby 3.0.0') }

      it 'returns relevant advisories' do
        expect(scanner.vulnerable_advisories).not_to be_empty
        expect(scanner.vulnerable_advisories.map(&:class).uniq).to eq([Bundler::Audit::Advisory])
      end
    end

    context "when bundler ruby version doesn't" do
      let(:bundler_ruby_version) { nil }

      it 'returns an empty array' do
        expect(scanner.vulnerable_advisories).to eq([])
      end
    end
  end
end
