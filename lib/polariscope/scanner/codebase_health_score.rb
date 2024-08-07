# frozen_string_literal: true

require 'tempfile'
require_relative 'gemfile_health_score'

module Polariscope
  module Scanner
    class CodebaseHealthScore
      def initialize(gemfile_content:, gemfile_lock_content:, bundler_audit_config_content:)
        @gemfile_content = gemfile_content
        @gemfile_lock_content = gemfile_lock_content
        @bundler_audit_config_content = bundler_audit_config_content
      end

      def health_score
        return nil if blank?(gemfile_content) || blank?(gemfile_lock_content)

        GemfileHealthScore.new(
          gemfile_path: gemfile_file.path,
          gemfile_lock_content: gemfile_lock_content,
          bundler_audit_config_path: bundler_audit_config_file.path
        ).health_score
      ensure
        gemfile_file.unlink
        bundler_audit_config_file.unlink
      end

      private

      attr_reader :gemfile_content
      attr_reader :gemfile_lock_content
      attr_reader :bundler_audit_config_content

      def gemfile_file
        @gemfile_file ||= begin
          file = Tempfile.new('Gemfile')
          file.write(gemfile_content.gsub("gemspec\n", ''))
          file.close
          file
        end
      end

      def bundler_audit_config_file
        @bundler_audit_config_file ||= begin
          file = Tempfile.new('.bundler-audit.yml')
          file.write(bundler_audit_config_content)
          file.close
          file
        end
      end

      def blank?(value)
        value.nil? || value == ''
      end
    end
  end
end
