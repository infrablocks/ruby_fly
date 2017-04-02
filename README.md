# RubyFly

Wraps the concourse fly CLI so that fly can be invoked from a Ruby script or 
Rakefile.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_fly'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_fly

## Usage

### Binary Location

RubyFly needs to know where the fly binary is located before it can do anything.
By default, RubyFly looks on the path however this can be configured with:

```ruby
RubyFly.configure do |config|
  config.binary = 'vendor/fly/bin/fly'
end
```

In addition, each command takes a `binary` keyword argument at initialisation
that overrides the global configuration value.

### Login

Currently the library doesn't support logging in to a Concourse instance so if
the target instance requires authentication, a session must be manually 
established before any commands are executed. If there are recommendations for
a good approach to automatic login, please raise an issue or a pull request.

### Commands

Currently, there is partial support for the following commands:
* `RubyFly::Commands::GetPipeline`: fetches the current configuration of a 
  pipeline from a target Concourse (`fly get-pipeline`)
* `RubyFly::Commands::SetPipeline`: submits a pipeline configuration to
  a target Concourse (`fly set-pipeline`)
* `RubyFly::Commands::UnpausePipeline`: unpauses a pipeline on a target
  Concourse (`fly unpause-pipeline`)
* `RubyFly::Commands::Version`: returns the version of the fly binary

#### `RubyFly::Commands::GetPipeline`

The get-pipeline command can be called in the following ways:

```ruby
RubyFly.get_pipeline(
    target: 'supercorp-ci', 
    pipeline: 'supercorp-service')
RubyFly::Commands::GetPipeline.new.execute(
    target: 'supercorp-ci',
    pipeline: 'supercorp-service')
```

The get-pipeline command supports the following options passed as keyword 
arguments (as in the example above):
* `target`: the Concourse instance to target
* `pipeline`: the pipeline for which to get configuration

#### `RubyFly::Commands::SetPipeline`

The set-pipeline command can be called in the following ways:

```ruby
RubyFly.set_pipeline(
    target: 'supercorp-ci', 
    pipeline: 'supercorp-service',
    config: 'ci/pipeline.yml')
RubyFly::Commands::SetPipeline.new.execute(
    target: 'supercorp-ci',
    pipeline: 'supercorp-service',
    config: 'ci/pipeline.yml')
```

The set-pipeline command supports the following options passed as keyword 
arguments (as in the example above):
* `target`: the Concourse instance to target
* `pipeline`: the pipeline for which to set configuration
* `config`: the local file containing the pipeline configuration
* `vars`: an hash of variables to be accessible as interpolations
* `var_files`: an array of paths to files containing variables to be accessible
  as interpolations
* `non_interactive`: if `false`, any missing variables will be prompted for,
  if `true`, any missing variables will cause the command to fail

#### `RubyFly::Commands::UnpausePipeline`

The unpause-pipeline command can be called in the following ways:

```ruby
RubyFly.unpause_pipeline(
    target: 'supercorp-ci', 
    pipeline: 'supercorp-service')
RubyFly::Commands::UnpausePipeline.new.execute(
    target: 'supercorp-ci',
    pipeline: 'supercorp-service')
```

The get-pipeline command supports the following options passed as keyword 
arguments (as in the example above):
* `target`: the Concourse instance to target
* `pipeline`: the pipeline to unpause

#### `RubyFly::Commands::Version`

The version command can be called in the following ways:

```ruby
version = RubyFly.version
version = RubyFly::Commands::Version.new.execute
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/tobyclemson/ruby_fly. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
