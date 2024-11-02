# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::GemfileHealthScore do
  describe '#new' do
    it 'updates audit database by default' do
      allow(Polariscope::Scanner::AuditDatabase).to receive(:update_if_necessary)

      described_class.new

      expect(Polariscope::Scanner::AuditDatabase).to have_received(:update_if_necessary)
    end

    it "doesn't update audit database when update_audit_database is false" do
      allow(Polariscope::Scanner::AuditDatabase).to receive(:update_if_necessary)

      described_class.new(update_audit_database: false)

      expect(Polariscope::Scanner::AuditDatabase).not_to have_received(:update_if_necessary)
    end
  end

  describe '#health_score' do
    subject(:health_score) do
      described_class.new(
        gemfile_content: gemfile_content,
        gemfile_lock_content: gemfile_lock_content,
        bundler_audit_config_content: bundler_audit_config_content
      ).health_score
    end

    context 'when no dependencies found' do
      let(:gemfile_content) { File.read('spec/files/gemfile_with_no_dependencies') }
      let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_no_dependencies') }
      let(:bundler_audit_config_content) { '' }

      it { is_expected.to be_nil }
    end

    # these tests run in the order they're defined and assert that each next test
    # has a score lower than the previous one
    describe 'scores', order: :defined do
      last_score = nil

      context 'when dependencies found and some new versions ignored' do
        let(:gemfile_content) { File.read('spec/files/gemfile_with_dependencies') }
        let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_dependencies') }
        let(:bundler_audit_config_content) { File.read('spec/files/bundler-audit') }

        it 'returns a score' do
          expect(health_score).to be <= 43.32

          last_score = health_score
        end
      end

      context 'when dependencies found and no new version is ignored' do
        let(:gemfile_content) { File.read('spec/files/gemfile_with_dependencies') }
        let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_dependencies') }
        let(:bundler_audit_config_content) { '' }

        it 'returns a score' do
          expect(health_score).to be < last_score

          last_score = health_score
        end
      end

      context 'when Gemfile.lock has a Ruby version' do
        let(:gemfile_content) { File.read('spec/files/gemfile_with_ruby_version') }
        let(:gemfile_lock_content) { File.read('spec/files/gemfile.lock_with_ruby_version') }
        let(:bundler_audit_config_content) { '' }

        it 'returns a score' do
          expect(health_score).to be < last_score
        end
      end
    end
  end
end
