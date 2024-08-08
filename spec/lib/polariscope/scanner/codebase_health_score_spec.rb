# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::CodebaseHealthScore do
  describe '#health_score' do
    subject(:score) do
      described_class.new(
        gemfile_content: gemfile_content,
        gemfile_lock_content: gemfile_lock_content,
        bundler_audit_config_content: bundler_audit_config_content
      ).health_score
    end

    let(:gemfile_content) { anything }
    let(:gemfile_lock_content) { anything }
    let(:bundler_audit_config_content) { anything }
    let(:gemfile_health_score) { instance_double(Polariscope::Scanner::GemfileHealthScore, health_score: anything) }

    before do
      allow(Polariscope::Scanner::GemfileHealthScore).to receive(:new).and_return(gemfile_health_score)
    end

    context 'when gemfile_content nil' do
      let(:gemfile_content) { nil }

      it { is_expected.to be_nil }
    end

    context 'when gemfile_content blank' do
      let(:gemfile_content) { '' }

      it { is_expected.to be_nil }
    end

    context 'when gemfile_lock_content nil' do
      let(:gemfile_lock_content) { nil }

      it { is_expected.to be_nil }
    end

    context 'when gemfile_lock_content blank' do
      let(:gemfile_lock_content) { '' }

      it { is_expected.to be_nil }
    end

    context 'when gemfile_content contains word gemspec' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:gemfile_content) { "gemspec\nOnlyThis" }
      let(:gemfile_lock_content) { 'gemfile lock content' }
      let(:bundler_audit_config_content) { 'BundlerAuditIgnore' }
      let(:gemfile_tempfile) { instance_double(Tempfile, write: :ok, close: :ok, unlink: :ok, path: 'Gemfile') }
      let(:audit_tempfile) { instance_double(Tempfile, write: :ok, close: :ok, unlink: :ok, path: 'bundler-audit') }

      before do
        allow(Tempfile).to receive(:new).with('Gemfile').and_return(gemfile_tempfile)
        allow(Tempfile).to receive(:new).with('.bundler-audit.yml').and_return(audit_tempfile)
      end

      it 'removes the line and leaves the rest in the file' do # rubocop:disable RSpec/MultipleExpectations
        score

        expect(Tempfile).to have_received(:new).with('Gemfile').once
        expect(gemfile_tempfile).to have_received(:write).with('OnlyThis').once
        expect(gemfile_tempfile).to have_received(:close).once
        expect(gemfile_tempfile).to have_received(:unlink).once

        expect(Tempfile).to have_received(:new).with('.bundler-audit.yml').once
        expect(audit_tempfile).to have_received(:write).with(bundler_audit_config_content).once
        expect(audit_tempfile).to have_received(:close).once
        expect(audit_tempfile).to have_received(:unlink).once
      end

      it 'sends args to Polariscope::Scanner::GemfileHealthScore' do
        score

        expect(Polariscope::Scanner::GemfileHealthScore).to have_received(:new).with(
          gemfile_path: 'Gemfile', gemfile_lock_content: gemfile_lock_content,
          bundler_audit_config_path: 'bundler-audit'
        )
      end
    end
  end
end
