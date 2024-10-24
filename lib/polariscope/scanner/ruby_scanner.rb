# frozen_string_literal: true

require 'bundler/audit/database'

module Polariscope
  module Scanner
    class RubyScanner
      def initialize(bundler_ruby_version)
        @bundler_ruby_version = bundler_ruby_version
      end

      def version
        bundler_ruby_version&.gem_version
      end

      def vulnerable_advisories
        version ? advisories.select { |a| a.vulnerable?(version) } : []
      end

      private

      attr_reader :bundler_ruby_version

      def advisories
        cve_paths.map { |path| Bundler::Audit::Advisory.load(path) }
      end

      # see https://github.com/rubysec/ruby-advisory-db?tab=readme-ov-file#directory-structure
      # and https://github.com/rubysec/bundler-audit/blob/da0eff072a9521dc2995483a8978d5a7dd4e328a/lib/bundler/audit/database.rb#L364
      def cve_paths
        Dir.glob(File.join(Bundler::Audit::Database.path, 'rubies', engine, '*.yml'))
      end

      def engine
        bundler_ruby_version.engine
      end
    end
  end
end
