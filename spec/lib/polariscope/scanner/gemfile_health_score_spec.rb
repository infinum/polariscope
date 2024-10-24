# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemfileHealthScore do
  subject(:score) do
    described_class.new(
      gemfile_path: gemfile_path,
      gemfile_lock_content: gemfile_lock_content,
      bundler_audit_config_path: bundler_audit_config_path,
      update_audit_database: update_audit_database
    ).health_score
  end

  let(:update_audit_database) { false }

  context 'when no dependencies found' do
    let(:gemfile_path) { File.join(Dir.pwd, 'spec/files/gemfile_with_no_dependencies') }
    let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_no_dependencies') }
    let(:bundler_audit_config_path) { '' }

    it { is_expected.to be_nil }
  end

  # these tests run in the order they're defined and assert that each next test
  # has a score lower than the previous one
  describe 'scores', order: :defined do
    last_score = nil

    context 'when dependencies found and some new versions ignored' do
      let(:gemfile_path) { File.join(Dir.pwd, 'spec/files/gemfile_with_dependencies') }
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_dependencies') }
      let(:bundler_audit_config_path) { File.join(Dir.pwd, 'spec/files/bundler-audit') }

      it 'returns a score' do
        expect(score).to be <= 43.32

        last_score = score
      end
    end

    context 'when dependencies found and no new version is ignored' do
      let(:gemfile_path) { File.join(Dir.pwd, 'spec/files/gemfile_with_dependencies') }
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_dependencies') }
      let(:bundler_audit_config_path) { '' }

      it 'returns a score' do
        expect(score).to be < last_score

        last_score = score
      end
    end

    context 'when Gemfile.lock has a Ruby version' do
      let(:gemfile_path) { File.join(Dir.pwd, 'spec/files/gemfile_with_ruby_version') }
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_ruby_version') }
      let(:bundler_audit_config_path) { '' }

      it 'returns a score' do
        expect(score).to be < last_score
      end
    end
  end

  context 'when update_audit_database is set to true' do
    let(:gemfile_path) { File.join(Dir.pwd, 'spec/files/gemfile_with_no_dependencies') }
    let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_no_dependencies') }
    let(:bundler_audit_config_path) { '' }
    let(:update_audit_database) { true }

    it 'updates Bundler::Audit::Database' do
      allow(Bundler::Audit::Database).to receive(:update!)

      score

      expect(Bundler::Audit::Database).to have_received(:update!).with(quiet: true).once
    end
  end
end
