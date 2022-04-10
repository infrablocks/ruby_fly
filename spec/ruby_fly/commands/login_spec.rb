# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Login do
  before do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after do
    RubyFly.reset!
  end

  it 'calls the fly login command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    allow(Open4).to(receive(:spawn))

    command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('fly login ' \
                  '-t=target',
                  any_args))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary login ' \
                  '-t=target',
                  any_args))
  end

  it_behaves_like(
    'a command with environment support',
    'login', ['-t=target'],
    { target: 'target' },
    'path/to/binary'
  )

  it 'throws ArgumentError if target is missing' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    expect do
      command.execute
    end.to(raise_error(
             ArgumentError,
             "Error: 'target' required but not provided."
           ))
  end

  it 'uses the provided concourse URL when supplied' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary login ' \
                  '-t=target ' \
                  '-c=https://concourse.example.com',
                  any_args))
  end

  it 'uses the provided username and password when supplied' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target',
      username: 'some-user',
      password: 'super-secret'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary login ' \
                  '-t=target ' \
                  '-c=https://concourse.example.com ' \
                  '-u=some-user ' \
                  '-p=super-secret',
                  any_args))
  end

  it 'adds a team when supplied' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      concourse_url: 'https://concourse.example.com',
      target: 'target',
      team: 'team'
    )

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary login ' \
                  '-t=target ' \
                  '-c=https://concourse.example.com ' \
                  '-n=team',
                  any_args))
  end
end
