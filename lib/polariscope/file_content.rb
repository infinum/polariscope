# frozen_string_literal: true

module Polariscope
  class FileContent < String
    class << self
      def for(path)
        file_path = File.join(Dir.pwd, path)

        File.exist?(file_path) ? new(File.read(file_path)) : new
      end
    end
  end
end
