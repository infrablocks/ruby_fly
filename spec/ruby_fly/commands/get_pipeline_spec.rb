# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::GetPipeline do
  before do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after do
    RubyFly.reset!
  end

  it 'calls the fly get-pipeline command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    allow(Open4).to(receive(:spawn))

    command.execute(
      target: 'target',
      pipeline: 'pipeline'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('fly get-pipeline ' \
                  '-t=target ' \
                  '-p=pipeline',
                  any_args))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      target: 'target',
      pipeline: 'pipeline'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary get-pipeline ' \
                  '-t=target ' \
                  '-p=pipeline',
                  any_args))
  end

  it_behaves_like(
    'a command with environment support',
    'get-pipeline',
    %w[-t=target -p=pipeline],
    { target: 'target', pipeline: 'pipeline' },
    'path/to/binary'
  )

  it 'throws ArgumentError if target or pipeline are missing' do
    command = described_class.new
    allow(Open4).to(receive(:spawn))

    %i[target pipeline].each do |required_parameter|
      expect do
        parameters = {
          target: 'target',
          pipeline: 'pipeline'
        }
        parameters.delete(required_parameter)

        command.execute(parameters)
      end.to(raise_error(
               ArgumentError,
               "Error: '#{required_parameter}' required but not provided."
             ))
    end
  end
end
