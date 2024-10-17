# frozen_string_literal: true

require 'bundler'
require 'bundler/audit/configuration'
require 'bundler/audit/database'
require 'set'
require_relative 'gem_versions'
require_relative 'gem_health_score'
require_relative 'ruby_scanner'

module Polariscope
  module Scanner
    class GemfileHealthScore # rubocop:disable Metrics/ClassLength
      GEM_PRIORITIES = { rails: 10.0 }.freeze
      DEFAULT_PRIORITY = 1.0
      GROUP_PRIORITIES = { default: 2.0, production: 2.0 }.freeze
      SEVERITIES = [1.7, 1.15, 1.01, 1.005].freeze
      FALLBACK_ADVISORY_PENALTY = 0.5
      ADVISORY_PENALTY_MAP = {
        none: 0.0,
        low: 0.5,
        medium: 1.0,
        high: 3.0,
        critical: 5.0
      }.freeze

      def initialize( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        gemfile_path:, gemfile_lock_content:, gem_priorities: GEM_PRIORITIES, default_priority: DEFAULT_PRIORITY,
        group_priorities: GROUP_PRIORITIES, severities: SEVERITIES, spec_type: :released,
        advisory_penalty_map: ADVISORY_PENALTY_MAP, fallback_advisory_penalty: FALLBACK_ADVISORY_PENALTY,
        update_audit_database: false, bundler_audit_config_path: ''
      )
        @lockfile_parser = Bundler::LockfileParser.new(gemfile_lock_content)
        @ruby_scanner = RubyScanner.new(@lockfile_parser)
        @gemfile_path = gemfile_path
        @dependencies = installed_dependencies
        @gem_priorities = gem_priorities
        @default_priority = default_priority
        @group_priorities = group_priorities
        @severities = severities
        @spec_type = spec_type
        @advisory_penalty_map = advisory_penalty_map
        @fallback_advisory_penalty = fallback_advisory_penalty
        @bundler_audit_config_path = bundler_audit_config_path

        update_audit_database! if update_audit_database
      end

      def health_score
        return nil if dependencies.empty?

        ((1.0 - major_version_penalty_score) * weighted_gem_health_score * advisories_score).round(2)
      end

      private

      attr_reader :dependencies
      attr_reader :lockfile_parser
      attr_reader :ruby_scanner
      attr_reader :advisory_penalty_map
      attr_reader :fallback_advisory_penalty
      attr_reader :bundler_audit_config_path

      def major_version_penalties
        dependencies.map do |dependency|
          current_version, all_versions = dependency_versions(dependency)

          GemHealthScore.new(all_versions: all_versions, current_version: current_version).major_version_penalty
        end
      end

      def major_version_penalty_score
        dependency_priorities.zip(major_version_penalties).sum { |a| a.inject(:*) } / dependency_priorities.sum
      end

      def weighted_gem_health_score
        dependency_priorities.zip(dependency_health_scores).sum { |a| a.inject(:*) } / dependency_priorities.sum
      end

      def dependency_health_scores
        dependencies.map do |dependency|
          current_version, all_versions = dependency_versions(dependency)

          GemHealthScore.new(
            all_versions: all_versions,
            current_version: current_version,
            severities: @severities
          ).health_score
        end
      end

      def dependency_priorities
        @dependency_priorities ||= dependencies.map { |dependency| dependency_priority(dependency) }
      end

      def dependency_priority(dependency)
        @gem_priorities[dependency.name.to_sym] || @group_priorities[dependency.groups.first] || @default_priority
      end

      def dependency_versions(dependency)
        [current_dependency_version(dependency), gem_versions.versions_for(dependency.name)]
      end

      def current_dependency_version(dependency)
        lockfile_parser.specs.find { |spec| dependency.name == spec.name }.version
      end

      def installed_dependencies
        spec_names = @lockfile_parser.specs.to_set(&:name)
        dependencies = Bundler::Definition.build(@gemfile_path, nil, nil).dependencies

        dependencies.select { |dependency| spec_names.include?(dependency.name) }
      end

      def gem_versions
        @gem_versions ||= GemVersions.new(dependencies.map(&:name), spec_type: @spec_type)
      end

      def advisories_score
        (1 + advisories_penalty)**-Math.log(1.09)
      end

      def advisories_penalty
        advisories.map(&:criticality)
                  .sum { |criticality| advisory_penalty_map.fetch(criticality, fallback_advisory_penalty) }
      end

      def advisories
        database = Bundler::Audit::Database.new

        lockfile_parser.specs
                       .flat_map { |gem| database.check_gem(gem).to_a }
                       .concat(ruby_scanner.vulnerable_advisories)
                       .reject { |advisory| ignored_advisories.intersect?(advisory.identifiers.to_set) }
      end

      def ignored_advisories
        @ignored_advisories ||= Bundler::Audit::Configuration.load(bundler_audit_config_path).ignore.to_set
      rescue Bundler::Audit::Configuration::FileNotFound, Bundler::Audit::Configuration::InvalidConfigurationError
        @ignored_advisories = Set.new
      end

      def update_audit_database!
        Bundler::Audit::Database.update!(quiet: true)
      end
    end
  end
end
