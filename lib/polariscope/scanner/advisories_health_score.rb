# frozen_string_literal: true

module Polariscope
  module Scanner
    class AdvisoriesHealthScore
      def initialize(dependency_context, calculation_context)
        @dependency_context = dependency_context
        @calculation_context = calculation_context
      end

      def health_score
        (1 + advisories_penalty)**-Math.log(calculation_context.advisory_severity)
      end

      private

      attr_reader :dependency_context
      attr_reader :calculation_context

      def advisories_penalty
        dependency_context
          .advisories
          .map(&:criticality)
          .sum { |criticality| calculation_context.advisory_penalty_for(criticality) }
      end
    end
  end
end
