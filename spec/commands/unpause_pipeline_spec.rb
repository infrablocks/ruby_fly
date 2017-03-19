require 'spec_helper'

describe RubyFly::Commands::UnpausePipeline do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly unpause-pipeline command passing the required arguments' do
    command = RubyFly::Commands::UnpausePipeline.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly unpause-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::UnpausePipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary unpause-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it 'throws ArgumentError if target or pipeline are missing' do
    command = RubyFly::Commands::UnpausePipeline.new
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
end
