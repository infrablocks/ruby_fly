require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::DestroyPipeline do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly destroy-pipeline command passing the required arguments' do
    command = RubyFly::Commands::DestroyPipeline.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly destroy-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::DestroyPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary destroy-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it_behaves_like("a command with environment support",
      'destroy-pipeline',
      ["-t=target", "-p=pipeline"],
      {target: 'target', pipeline: 'pipeline'},
      'path/to/binary')

  it 'throws ArgumentError if target or pipeline are missing' do
    command = RubyFly::Commands::DestroyPipeline.new
    allow(Open4).to(receive(:spawn))

    [:target, :pipeline].each do |required_parameter|
      expect {
        parameters = {
            target: 'target',
            pipeline: 'pipeline'
        }
        parameters.delete(required_parameter)

        command.execute(parameters)
      }.to raise_error(
               ArgumentError,
               "Error: '#{required_parameter}' required but not provided.")
    end
  end

  it 'adds a non-interactive flag when non interactive supplied' do
    command = RubyFly::Commands::DestroyPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary destroy-pipeline ' +
                '-t=target ' +
                '-p=pipeline ' +
                '-n',
                any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        non_interactive: true)
  end

  it 'adds a team when supplied' do
    command = RubyFly::Commands::DestroyPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary destroy-pipeline ' +
                '-t=target ' +
                '-p=pipeline ' +
                '--team=team',
                any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline',
        team: 'team')
  end
end
