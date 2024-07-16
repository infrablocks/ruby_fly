# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::DestroyPipeline do
  let(:executor) { Lino::Executors::Mock.new }

  before do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
    Lino.configure do |config|
      config.executor = executor
    end
  end

  after do
    Lino.reset!
    RubyFly.reset!
  end

  it 'calls the fly destroy-pipeline command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    command.execute(
      target: 'target',
      pipeline: 'pipeline'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('fly destroy-pipeline -t=target -p=pipeline'))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary destroy-pipeline -t=target -p=pipeline'))
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

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      non_interactive: true
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary destroy-pipeline -t=target -p=pipeline -n'))
  end

  it 'adds a team when supplied' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      team: 'team'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq(
            'path/to/binary destroy-pipeline -t=target -p=pipeline --team=team'
          ))
  end
end
