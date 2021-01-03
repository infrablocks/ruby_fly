require 'spec_helper'

describe RubyFly::Commands::GetPipeline do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly get-pipeline command passing the required arguments' do
    command = RubyFly::Commands::GetPipeline.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly get-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::GetPipeline.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary get-pipeline ' +
                      '-t=target ' +
                      '-p=pipeline',
                  any_args))

    command.execute(
        target: 'target',
        pipeline: 'pipeline')
  end

  it 'throws ArgumentError if target or pipeline are missing' do
    command = RubyFly::Commands::GetPipeline.new
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
