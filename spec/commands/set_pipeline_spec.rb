require 'spec_helper'

describe RubyFly::Commands::SetPipeline do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly set-pipeline command pasing the required arguments' do
    command = RubyFly::Commands::SetPipeline.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly set-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline ' +
                      '-c=config/file.yml',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        config: 'config/file.yml')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::SetPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary set-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline ' +
                      '-c=config/file.yml',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        config: 'config/file.yml')
  end

  it 'throws ArgumentError if target, pipeline or config are missing' do
    command = RubyFly::Commands::SetPipeline.new
    allow(Open4).to(receive(:spawn))

    [:target, :pipeline, :config].each do |required_parameter|
      expect {
        parameters = {
            target: 'target',
            pipeline: 'pipeline',
            config: 'config/file.yml'
        }
        parameters.delete(required_parameter)

        command.execute(parameters)
      }.to raise_error(
               ArgumentError,
               "Error: '#{required_parameter}' required but not provided.")
    end
  end

  it 'adds a var option for each supplied var' do
    command = RubyFly::Commands::SetPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary set-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline ' +
                      '-c=config/file.yml ' +
                      "-v='key1=value1' " +
                      "-v='key2=value2'",
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        config: 'config/file.yml',
        vars: {
            key1: 'value1',
            key2: 'value2'
        })
  end

  it 'adds a load_vars_from option for each supplied var file' do
    command = RubyFly::Commands::SetPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary set-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline ' +
                      '-c=config/file.yml ' +
                      "-l=config/variables.yml " +
                      "-l=config/secrets.yml",
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        config: 'config/file.yml',
        var_files: ['config/variables.yml', 'config/secrets.yml'])
  end

  it 'adds a non-interactive flag when non interactive supplied' do
    command = RubyFly::Commands::SetPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary set-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline ' +
                      '-c=config/file.yml ' +
                      '-n',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        config: 'config/file.yml',
        non_interactive: true)
  end
end
