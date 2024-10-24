# frozen_string_literal: true

require_relative 'advisories_health_score'
require_relative 'audit_database'
require_relative 'calculation_context'
require_relative 'dependency_context'
require_relative 'gem_health_score'

module Polariscope
  module Scanner
    class GemfileHealthScore
      def initialize(**opts)
        @dependency_context = DependencyContext.new(**opts)
        @calculation_context = CalculationContext.new(**opts)

        AuditDatabase.update_if_necessary
      end

      def health_score
        return nil if dependency_context.no_dependencies?

        (100.0 * weighted_major_version_score * weighted_dependency_health_score * advisories_score).round(2)
      end

      private

      attr_reader :dependency_context
      attr_reader :calculation_context

      def weighted_major_version_score
        1.0 - weighted_major_version_penalty
      end

      def weighted_major_version_penalty
        dependency_priorities.zip(major_version_penalties).sum { |a, b| a * b } / dependency_priorities.sum
      end

      def weighted_dependency_health_score
        dependency_priorities.zip(dependency_health_scores).sum { |a, b| a * b } / dependency_priorities.sum
      end

      def major_version_penalties
        gem_health_scores.map(&:major_version_penalty)
      end

      def dependency_health_scores
        gem_health_scores.map(&:health_score)
      end

      def gem_health_scores
        @gem_health_scores ||= dependencies.map do |dependency|
          GemHealthScore.new(dependency_context, calculation_context, dependency)
        end
      end

      def dependency_priorities
        @dependency_priorities ||= dependencies.map { |dependency| calculation_context.priority_for(dependency) }
      end

      def advisories_score
        AdvisoriesHealthScore.new(dependency_context, calculation_context).health_score
      end

      def dependencies
        dependency_context.dependencies
      end
    end
  end
end
