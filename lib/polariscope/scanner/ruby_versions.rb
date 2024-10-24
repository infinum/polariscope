# frozen_string_literal: true

require 'open-uri'

module Polariscope
  module Scanner
    module RubyVersions
      VERSIONS_INDEX_FILE_URL = 'https://cache.ruby-lang.org/pub/ruby/index.txt'
      MINIMUM_RUBY_VERSION = Gem::Version.new('1.0.0')
      OPEN_TIMEOUT = 5
      READ_TIMEOUT = 5

      module_function

      def available_versions
        URI
          .parse(VERSIONS_INDEX_FILE_URL)
          .open(open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT, &:readlines)
          .drop(1) # header row
          .map { |line| line.split("\t").first.sub('ruby-', 'ruby ') } # ruby-2.3.4 -> ruby 2.3.4
          .filter_map { |ruby_version| Bundler::RubyVersion.from_string(ruby_version)&.gem_version }
          .select { |gem_version| gem_version >= MINIMUM_RUBY_VERSION }
          .to_set
      rescue Timeout::Error
        Set.new
      end
    end
  end
end
