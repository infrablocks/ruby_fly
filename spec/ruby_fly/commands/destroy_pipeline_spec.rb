# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::DestroyPipeline do
  before do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after do
    RubyFly.reset!
  end

  it 'calls the fly destroy-pipeline command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    allow(Open4).to(receive(:spawn))

    command.execute(
      target: 'target',
      pipeline: 'pipeline'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('fly destroy-pipeline ' \
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
            .with('path/to/binary destroy-pipeline ' \
                  '-t=target ' \
                  '-p=pipeline',
                  any_args))
  end

  it_behaves_like(
    'a command with environment support',
    'destroy-pipeline',
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

  it 'adds a non-interactive flag when non interactive supplied' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      non_interactive: true
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary destroy-pipeline ' \
                  '-t=target ' \
                  '-p=pipeline ' \
                  '-n',
                  any_args))
  end

  it 'adds a team when supplied' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      team: 'team'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary destroy-pipeline ' \
                  '-t=target ' \
                  '-p=pipeline ' \
                  '--team=team',
                  any_args))
  end
end
