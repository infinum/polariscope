# frozen_string_literal: true

require 'set'

module Polariscope
  module Scanner
    class GemVersions
      def initialize(dependency_names, spec_type:)
        @dependency_names = dependency_names.to_set
        @spec_type = spec_type
        @gem_versions = Hash.new { |h, k| h[k] = Set.new }

        fetch_gems
      end

      def versions_for(gem_name)
        gem_versions[gem_name]
      end

      private

      attr_reader :dependency_names
      attr_reader :spec_type
      attr_reader :gem_versions

      def fetch_gems
        gem_tuples.each { |(name_tuple, _)| gem_versions[name_tuple.name] << name_tuple.version }
      end

      def gem_tuples
        Gem::SpecFetcher.fetcher.detect(spec_type) { |name_tuple| dependency_names.include?(name_tuple.name) }
      end
    end
  end
end
