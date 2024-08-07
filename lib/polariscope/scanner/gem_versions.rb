# frozen_string_literal: true

require 'set'

module Polariscope
  module Scanner
    class GemVersions
      def initialize(dependency_names, spec_type:)
        @dependency_names = dependency_names.to_set
        @spec_type = spec_type
        @gem_versions = Hash.new { |h, k| h[k] = [] }

        fetch_gems
      end

      def versions_for(gem_name)
        @gem_versions[gem_name]
      end

      private

      def fetch_gems
        gem_tuples = Gem::SpecFetcher.fetcher.detect(@spec_type) do |name_tuple|
          @dependency_names.include?(name_tuple.name)
        end

        gem_tuples.each { |gem_tuple| @gem_versions[gem_tuple.first.name] << gem_tuple.first.version }
      end
    end
  end
end
