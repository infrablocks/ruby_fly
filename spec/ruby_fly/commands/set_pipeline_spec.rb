# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::SetPipeline do
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

  it 'calls the fly set-pipeline command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('fly set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml'))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml'))
  end

  it_behaves_like(
    'a command with environment support',
    'set-pipeline',
    %w[-t=target -p=pipeline -c=config/file.yml],
    { target: 'target', pipeline: 'pipeline',
      config: 'config/file.yml' },
    'path/to/binary'
  )

  it 'throws ArgumentError if target, pipeline or config are missing' do
    command = described_class.new

    %i[target pipeline config].each do |required_parameter|
      expect do
        parameters = {
          target: 'target',
          pipeline: 'pipeline',
          config: 'config/file.yml'
        }
        parameters.delete(required_parameter)

        command.execute(parameters)
      end.to(raise_error(
               ArgumentError,
               "Error: '#{required_parameter}' required but not provided."
             ))
    end
  end

  it 'adds a var option for each supplied var' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml',
      vars: {
        key1: 'value1',
        key2: 'value2'
      }
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml ' \
             "-v='key1=value1' " \
             "-v='key2=value2'"))
  end

  it 'adds a load_vars_from option for each supplied var file' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml',
      var_files: %w[config/variables.yml config/secrets.yml]
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml ' \
             '-l=config/variables.yml ' \
             '-l=config/secrets.yml'))
  end

  it 'adds a non-interactive flag when non interactive supplied' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml',
      non_interactive: true
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml ' \
             '-n'))
  end

  it 'adds a team when supplied' do
    command = described_class.new

    command.execute(
      target: 'target',
      pipeline: 'pipeline',
      config: 'config/file.yml',
      team: 'team'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary set-pipeline ' \
             '-t=target ' \
             '-p=pipeline ' \
             '-c=config/file.yml ' \
             '--team=team'))
  end
end
