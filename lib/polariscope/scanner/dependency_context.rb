# frozen_string_literal: true

require_relative 'ruby_scanner'

require 'tempfile'
require 'bundler/audit/configuration'

module Polariscope
  module Scanner
    class DependencyContext
      DEFAULT_SPEC_TYPE = :released

      def initialize(**opts)
        @gemfile_content = opts.fetch(:gemfile_content, nil)
        @gemfile_lock_content = opts.fetch(:gemfile_lock_content, nil)
        @bundler_audit_config_content = opts.fetch(:bundler_audit_config_content, '')
        @spec_type = opts.fetch(:spec_type, DEFAULT_SPEC_TYPE)
      end

      def no_dependencies?
        blank_value?(gemfile_content) || blank_value?(gemfile_lock_content) || dependencies.empty?
      end

      def dependencies
        @dependencies ||= dependencies_with_ruby
      end

      def dependency_versions(dependency)
        [current_dependency_version(dependency), gem_versions.versions_for(dependency.name)]
      end

      def advisories
        specs
          .flat_map { |gem| audit_database.check_gem(gem).to_a }
          .concat(ruby_scanner.vulnerable_advisories)
          .reject { |advisory| ignored_advisories.intersect?(advisory.identifiers.to_set) }
      end

      private

      attr_reader :gemfile_content
      attr_reader :gemfile_lock_content
      attr_reader :bundler_audit_config_content
      attr_reader :spec_type

      def ruby_scanner
        @ruby_scanner ||= RubyScanner.new(bundle_definition.locked_ruby_version_object)
      end

      def gem_versions
        @gem_versions ||= GemVersions.new(dependencies.map(&:name), spec_type: spec_type)
      end

      def bundle_definition
        @bundle_definition ||=
          ::Tempfile.create do |gemfile|
            ::Tempfile.create do |gemfile_lock|
              gemfile.puts parseable_gemfile_content
              gemfile.rewind

              gemfile_lock.puts gemfile_lock_content
              gemfile_lock.rewind

              Bundler::Definition.build(gemfile.path, gemfile_lock.path, false)
            end
          end
      end

      def current_dependency_version(dependency)
        return ruby_scanner.version if dependency.name == GemVersions::RUBY_NAME

        specs.find { |spec| dependency.name == spec.name }.version
      end

      def dependencies_with_ruby
        return bundle_definition.dependencies unless ruby_scanner.version

        bundle_definition.dependencies + [Bundler::Dependency.new(GemVersions::RUBY_NAME, false)]
      end

      def specs
        bundle_definition.locked_gems.specs
      end

      def ignored_advisories
        audit_configuration.ignore
      end

      def audit_configuration
        @audit_configuration ||= Tempfile.create do |file|
          file.puts bundler_audit_config_content
          file.rewind

          Bundler::Audit::Configuration.load(file.path)
        rescue StandardError
          Bundler::Audit::Configuration.new
        end
      end

      def audit_database
        @audit_database ||= Bundler::Audit::Database.new
      end

      def parseable_gemfile_content
        gemfile_content.gsub("gemspec\n", '').gsub(/^ruby.*$\R/, '')
      end

      def blank_value?(value)
        value.nil? || value.empty?
      end
    end
  end
end
