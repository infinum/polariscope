# Polariscope

Polariscope is a Ruby gem designed to evaluate the overall health of your Ruby application by analyzing its dependencies. It calculates a health score based on how many dependencies are outdated, meaning there are newer versions available. Keeping dependencies up-to-date is crucial for maintaining application security, performance, and compatibility. This gem provides a quick and easy way to gauge the state of your project's dependencies and take proactive measures to improve its health.

### Health Score Algorithm

The health score calculation is based on the following mathematical formula:

![Health Score Algorithm](docs/algorithm.png)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add polariscope

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install polariscope

### Known issue

If your default Ruby version is 3.1.2, you might get this error when installing polariscope:

```bash
.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/rdoc-6.7.0/lib/rdoc/version.rb:8: warning: already initialized constant RDoc::VERSION
ERROR:  While executing gem ... (NameError)
    uninitialized constant RDoc::Markdown

    'markdown' => RDoc::Markdown,
                      ^^^^^^^^^^
```

You can ignore this error. It doesn't occur in other Ruby versions and it doesn't prevent you from using polariscope.

## Usage

Polariscope can be used in 2 ways.

### CLI

Position yourself in a Ruby application and run:

```bash
polariscope scan
```

### IRB / Rails

```ruby
Polariscope.scan
```

The return value will indicate how healthy your project is on a scale from 0 to 100.

#### Additional features

##### Score color

Get the score color for a score:

```ruby
Polariscope.score_color(60.75)
```

##### Gem versions

Get the released or latest version of gems with:

```ruby
# released versions
gem_specs = Polariscope.gem_versions(['gem_name_1', 'gem_name_2'])
gem_specs.versions_for('gem_name_1') # => returns potentially many versions

# latest version
gem_specs = Polariscope.gem_versions(['gem_name_1', 'gem_name_2'], spec_type: :latest)
gem_specs.versions_for('gem_name_1') # => returns latest version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infinum/polariscope.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
