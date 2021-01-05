require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Login do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly login command passing the required arguments' do
    command = RubyFly::Commands::Login.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly login ' +
                '-t=target',
                any_args))

    command.execute(target: 'target')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::Login.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary login ' +
                '-t=target',
                any_args))

    command.execute(target: 'target')
  end

  it_behaves_like("a command with environment support",
      'login', ["-t=target"], {target: 'target'}, 'path/to/binary')

  it 'throws ArgumentError if target is missing' do
    command = RubyFly::Commands::Login.new
    allow(Open4).to(receive(:spawn))

    expect {
      command.execute
    }.to raise_error(
        ArgumentError,
        "Error: 'target' required but not provided.")
  end

  it 'uses the provided concourse URL when supplied' do
    command = RubyFly::Commands::Login.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary login ' +
                '-t=target ' +
                '-c=https://concourse.example.com',
                any_args))

    command.execute(
        concourse_url: 'https://concourse.example.com',
        target: 'target')
  end

  it 'uses the provided username and password when supplied' do
    command = RubyFly::Commands::Login.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary login ' +
                '-t=target ' +
                '-c=https://concourse.example.com ' +
                '-u=some-user ' +
                '-p=super-secret',
                any_args))

    command.execute(
        concourse_url: 'https://concourse.example.com',
        target: 'target',
        username: 'some-user',
        password: 'super-secret')
  end

  it 'adds a team when supplied' do
    command = RubyFly::Commands::Login.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary login ' +
                '-t=target ' +
                '-c=https://concourse.example.com ' +
                '-n=team',
                any_args))

    command.execute(
        concourse_url: 'https://concourse.example.com',
        target: 'target',
        team: 'team')
  end
end
