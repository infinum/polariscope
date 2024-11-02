# frozen_string_literal: true

require 'bundler'

require_relative 'polariscope/version'
require_relative 'polariscope/scanner/gemfile_health_score'
require_relative 'polariscope/scanner/gem_versions'
require_relative 'polariscope/file_content'

module Polariscope
  Error = Class.new(StandardError)

  class << self
    def scan(**opts)
      Scanner::GemfileHealthScore.new(
        **opts,
        gemfile_content: opts.fetch(:gemfile_content, FileContent.for('Gemfile')),
        gemfile_lock_content: opts.fetch(:gemfile_lock_content, FileContent.for('Gemfile.lock')),
        bundler_audit_config_content: opts.fetch(:bundler_audit_config_content, FileContent.for('.bundler-audit.yml'))
      ).health_score
    end

    def gem_versions(dependency_names, spec_type: Scanner::DependencyContext::DEFAULT_SPEC_TYPE)
      Scanner::GemVersions.new(dependency_names, spec_type: spec_type)
    end
  end
end
