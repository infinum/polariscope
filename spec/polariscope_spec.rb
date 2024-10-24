# frozen_string_literal: true

RSpec.describe Polariscope do
  it 'has a version number' do
    expect(Polariscope::VERSION).not_to be_nil
  end

  describe '.scan' do
    let(:scanner) { instance_double(Polariscope::Scanner::GemfileHealthScore, health_score: 100) }

    before do
      allow(Polariscope::Scanner::GemfileHealthScore).to receive(:new).and_return(scanner)
    end

    it 'calls Scanner::GemfileHealthScore' do
      expect(described_class.scan).to eq(100)
    end

    context 'when no arguments passed' do
      before do
        allow(Polariscope::FileContent).to receive(:for).with('Gemfile').and_return('Gemfile contents')
        allow(Polariscope::FileContent).to receive(:for).with('Gemfile.lock').and_return('Gemfile lock contents')
        allow(Polariscope::FileContent).to receive(:for).with('.bundler-audit.yml').and_return('audit yml contents')
      end

      it 'passes FileContent arguments to scanner' do
        args = {
          gemfile_content: 'Gemfile contents',
          gemfile_lock_content: 'Gemfile lock contents',
          bundler_audit_config_content: 'audit yml contents'
        }

        described_class.scan

        expect(Polariscope::Scanner::GemfileHealthScore).to have_received(:new).with(**args)
      end
    end

    context 'when arguments passed' do
      it 'passes content arguments to scanner' do
        args = { gemfile_content: '1', gemfile_lock_content: '2', bundler_audit_config_content: '3' }

        described_class.scan(**args)

        expect(Polariscope::Scanner::GemfileHealthScore).to have_received(:new).with(**args)
      end
    end
  end

  describe '.gem_versions' do
    it 'calls Scanner::GemVersions' do
      allow(Polariscope::Scanner::GemVersions).to receive(:new).and_return(anything)

      described_class.gem_versions(['gem', 'another_gem'])

      expect(Polariscope::Scanner::GemVersions)
        .to have_received(:new).with(['gem', 'another_gem'], spec_type: :released)
    end
  end
end
