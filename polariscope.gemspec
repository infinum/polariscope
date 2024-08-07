# frozen_string_literal: true

require_relative 'lib/polariscope/version'

Gem::Specification.new do |spec|
  spec.name = 'polariscope'
  spec.version = Polariscope::VERSION
  spec.authors = ['Rails team']
  spec.email = ['team.rails@infinum.com']

  spec.summary = 'Tool for determining the health of a project based on the state of dependencies'
  spec.homepage = 'https://github.com/infinum/polariscope'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/infinum/polariscope'
  spec.metadata['changelog_uri'] = 'https://github.com/infinum/polariscope/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|sig)/|\.(?:git|circleci)|appveyor)})
    end + Dir['exe/polariscope'] + Dir['lib/**/*']
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler'
  spec.add_dependency 'bundler-audit'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
