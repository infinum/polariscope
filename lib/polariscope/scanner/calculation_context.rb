# frozen_string_literal: true

module Polariscope
  module Scanner
    class CalculationContext
      DEPENDENCY_PRIORITIES = { ruby: 10.0, rails: 10.0 }.freeze
      GROUP_PRIORITIES = { default: 2.0, production: 2.0 }.freeze
      DEFAULT_DEPENDENCY_PRIORITY = 1.0

      ADVISORY_SEVERITY = 1.09
      ADVISORY_PENALTIES = {
        none: 0.0,
        low: 0.5,
        medium: 1.0,
        high: 3.0,
        critical: 5.0
      }.freeze
      FALLBACK_ADVISORY_PENALTY = 0.5

      MAJOR_VERSION_PENALTY = 1
      NEW_VERSIONS_SEVERITY = 1.07
      SEGMENT_SEVERITIES = [1.7, 1.15, 1.01].freeze
      FALLBACK_SEGMENT_SEVERITY = 1.0

      def initialize(**opts)
        @dependency_priorities = opts.fetch(:dependency_priorities, DEPENDENCY_PRIORITIES)
        @group_priorities = opts.fetch(:group_priorities, GROUP_PRIORITIES)
        @default_dependency_priority = opts.fetch(:default_dependency_priority, DEFAULT_DEPENDENCY_PRIORITY)

        @advisory_severity = opts.fetch(:advisory_severity, ADVISORY_SEVERITY)
        @advisory_penalties = opts.fetch(:advisory_penalties, ADVISORY_PENALTIES)
        @fallback_advisory_penalty = opts.fetch(:fallback_advisory_penalty, FALLBACK_ADVISORY_PENALTY)

        @major_version_penalty = opts.fetch(:major_version_penalty, MAJOR_VERSION_PENALTY)
        @new_versions_severity = opts.fetch(:new_versions_severity, NEW_VERSIONS_SEVERITY)
        @segment_severities = opts.fetch(:segment_severities, SEGMENT_SEVERITIES)
        @fallback_segment_severity = opts.fetch(:fallback_segment_severity, FALLBACK_SEGMENT_SEVERITY)
      end

      def priority_for(dependency)
        dependency_priorities[dependency.name.to_sym] ||
          group_priorities[dependency.groups.first] ||
          default_dependency_priority
      end

      def advisory_penalty_for(criticality)
        advisory_penalties.fetch(criticality, fallback_advisory_penalty)
      end

      def segment_severity(segment)
        return 1.0 unless segment

        segment_severities.fetch(segment, fallback_segment_severity)
      end

      attr_reader :advisory_severity
      attr_reader :new_versions_severity
      attr_reader :major_version_penalty

      private

      attr_reader :dependency_priorities
      attr_reader :default_dependency_priority
      attr_reader :group_priorities
      attr_reader :advisory_penalties
      attr_reader :fallback_advisory_penalty
      attr_reader :segment_severities
      attr_reader :fallback_segment_severity
    end
  end
end
