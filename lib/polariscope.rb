# frozen_string_literal: true

require_relative 'polariscope/version'
require_relative 'polariscope/scanner/codebase_health_score'
require_relative 'polariscope/scanner/gem_versions'
require_relative 'polariscope/file_content'

module Polariscope
  Error = Class.new(StandardError)

  class << self
    def scan(gemfile_content: nil, gemfile_lock_content: nil, bundler_audit_config_content: nil)
      Scanner::CodebaseHealthScore.new(
        gemfile_content: gemfile_content || FileContent.for('Gemfile'),
        gemfile_lock_content: gemfile_lock_content || FileContent.for('Gemfile.lock'),
        bundler_audit_config_content: bundler_audit_config_content || FileContent.for('.bundler-audit.yml')
      ).health_score
    end

    def gem_versions(dependency_names, spec_type: :released)
      Scanner::GemVersions.new(dependency_names, spec_type: spec_type)
    end
  end
end
