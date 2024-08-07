# frozen_string_literal: true

module Polariscope
  module Scanner
    class GemHealthScore
      def initialize(all_versions:, current_version:, severities: [])
        @all_versions = all_versions
        @current_version = current_version
        @severities = severities
      end

      def health_score
        return 100 if up_to_date?

        score = 100
        score *= (1.0 + first_outdated_segment)**-Math.log(first_outdated_segment_severity)
        score *= (1.0 + new_versions.count)**-Math.log(1.07)
        score
      end

      def up_to_date?
        current_version == latest_version
      end

      def first_outdated_segment_severity
        return 1 if first_outdated_segment_index.nil?

        severities[first_outdated_segment_index]
      end

      def first_outdated_segment_index
        segments_delta.find_index(&:positive?)
      end

      def first_outdated_segment
        segments_delta.find(&:positive?) || 0
      end

      def segments_delta
        current_version.segments.grep(Integer).zip(latest_version.segments.grep(Integer))
                       .map { |current, latest| current && latest ? latest - current : 0 }
      end

      def major_version_penalty
        major_outdated? ? 1 : 0
      end

      def major_outdated?
        latest_version.segments[0] > current_version.segments[0]
      end

      def latest_version
        @latest_version ||= new_versions.max || current_version
      end

      def new_versions
        @new_versions ||= all_versions.select { |version| version > current_version }
      end

      private

      attr_reader :all_versions
      attr_reader :current_version
      attr_reader :severities
    end
  end
end
