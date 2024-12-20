# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
end

require 'polariscope'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  database_path = File.join(__dir__, '../tmp/database')

  config.before(:suite) do
    FileUtils.rm_rf([database_path])
    system 'git', 'clone', '--quiet', '--depth', '1', Bundler::Audit::Database::URL, database_path
  end

  config.before do
    stub_const('Bundler::Audit::Database::DEFAULT_PATH', database_path)
  end
end
