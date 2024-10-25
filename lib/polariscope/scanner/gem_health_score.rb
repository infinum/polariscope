# frozen_string_literal: true

module Polariscope
  module Scanner
    class GemHealthScore
      def initialize(dependency_context, calculation_context, dependency)
        @calculation_context = calculation_context

        @current_version, @all_versions = dependency_context.dependency_versions(dependency)
      end

      def health_score
        return 1.0 if up_to_date?

        score = 1.0
        score *= (1 + first_outdated_segment)**-Math.log(first_outdated_segment_severity)
        score *= (1 + new_versions.count)**-Math.log(calculation_context.new_versions_severity)
        score
      end

      def major_version_penalty
        major_version_outdated? ? calculation_context.major_version_penalty : 0
      end

      private

      attr_reader :calculation_context
      attr_reader :current_version
      attr_reader :all_versions

      def up_to_date?
        current_version == latest_version
      end

      def first_outdated_segment_severity
        calculation_context.segment_severity(first_outdated_segment_index)
      end

      def first_outdated_segment_index
        segments_delta.find_index(&:positive?)
      end

      def first_outdated_segment
        segments_delta.find(&:positive?) || 0
      end

      def major_version_outdated?
        segments_delta.first.positive?
      end

      def segments_delta
        @segments_delta ||=
          version_segments(latest_version)
          .zip(version_segments(current_version))
          .map { |latest, current| latest && current ? latest - current : 0 }
      end

      def latest_version
        @latest_version ||= new_versions.max || current_version
      end

      def new_versions
        @new_versions ||= all_versions.select { |version| version > current_version }
      end

      def version_segments(version)
        version.segments.grep(Integer)
      end
    end
  end
end
