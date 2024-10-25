# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::AuditDatabase do
  subject(:audit_database) { described_class }

  let(:database_instance) { Bundler::Audit::Database.new }

  before do
    allow(Bundler::Audit::Database).to receive(:new).and_return(database_instance)
    allow(Bundler::Audit::Database).to receive(:update!)
  end

  describe '.update_if_necessary' do
    context 'when database exists and is up-to-date' do
      before do
        allow(Bundler::Audit::Database).to receive(:exists?).and_return(true)
        allow(database_instance).to receive(:last_updated_at).and_return(Time.now)
      end

      it "doesn't update the database" do
        audit_database.update_if_necessary

        expect(Bundler::Audit::Database).not_to have_received(:update!)
      end
    end

    context 'when database exists but is not up-to-date' do
      before do
        allow(Bundler::Audit::Database).to receive(:exists?).and_return(true)
        allow(database_instance).to receive(:last_updated_at).and_return(Time.now - 86_401)
      end

      it 'updates the database' do
        audit_database.update_if_necessary

        expect(Bundler::Audit::Database).to have_received(:update!).with(quiet: true)
      end
    end

    context "when database doesn't exist" do
      before do
        allow(Bundler::Audit::Database).to receive(:exists?).and_return(false)
      end

      it 'updates the database' do
        audit_database.update_if_necessary

        expect(Bundler::Audit::Database).to have_received(:update!).with(quiet: true)
      end
    end
  end
end
