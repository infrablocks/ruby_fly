# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Login do
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

  it 'calls the fly login command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('fly login -t=target'))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary login -t=target'))
  end

  it_behaves_like(
    'a command with environment support',
    'login', ['-t=target'],
    { target: 'target' },
    'path/to/binary'
  )

  it 'throws ArgumentError if target is missing' do
    command = described_class.new

    expect do
      command.execute
    end.to(raise_error(
             ArgumentError,
             "Error: 'target' required but not provided."
           ))
  end

  it 'uses the provided concourse URL when supplied' do
    command = described_class.new

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary login -t=target -c=https://concourse.example.com'))
  end

  it 'uses the provided username and password when supplied' do
    command = described_class.new

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target',
      username: 'some-user',
      password: 'super-secret'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq(
            'path/to/binary login ' \
            '-t=target ' \
            '-c=https://concourse.example.com ' \
            '-u=some-user ' \
            '-p=super-secret'
          ))
  end

  it 'adds a team when supplied' do
    command = described_class.new

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target',
      team: 'team'
    )

    expect(executor.executions.first.command_line.string)
      .to(eq(
            'path/to/binary login ' \
            '-t=target ' \
            '-c=https://concourse.example.com ' \
            '-n=team'
          ))
  end
end
