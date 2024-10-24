# frozen_string_literal: true

require 'bundler/audit/database'

module Polariscope
  module Scanner
    module AuditDatabase
      extend self

      ONE_DAY = 24 * 60 * 60

      def update_if_necessary
        update_audit_database! if database_outdated?
      end

      private

      def update_audit_database!
        Bundler::Audit::Database.update!(quiet: true)
      end

      def database_outdated?
        audit_db_missing? || audit_db_stale?
      end

      def audit_db_missing?
        !Bundler::Audit::Database.exists?
      end

      def audit_db_stale?
        ((Time.now - Bundler::Audit::Database.new.last_updated_at) / ONE_DAY) > 1.0
      end
    end
  end
end
