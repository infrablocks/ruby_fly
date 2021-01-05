require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Status do
  before(:each) do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after(:each) do
    RubyFly.reset!
  end

  it 'calls the fly status command passing the required arguments' do
    command = RubyFly::Commands::Status.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly status ' +
                '-t=target',
                any_args))

    command.execute(target: 'target')
  end

  it 'defaults to the configured binary when none provided' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args))

    command.execute(target: 'target')
  end

  it_behaves_like("a command with environment support",
      'status', ["-t=target"], {target: 'target'}, 'path/to/binary')

  it 'throws ArgumentError if target is missing' do
    command = RubyFly::Commands::Status.new
    allow(Open4).to(receive(:spawn))

    expect {
      command.execute
    }.to raise_error(
        ArgumentError,
        "Error: 'target' required but not provided.")
  end

  it 'converts the output to a symbol and returns when logged in' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args) { |_, opts|
              opts[:stdout].write("logged in successfully\n")
            })

    result = command.execute(target: 'target')

    expect(result).to(eq(:logged_in))
  end

  it 'converts the output to a symbol and returns when logged out' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args) { |_, opts|
              opts[:stderr].write("logged out\n")
              raise Open4::SpawnError.new(
                  'cmd',
                  double('status', {
                      signaled?: false,
                      exitstatus: 1
                  }))
            })

    result = command.execute(target: 'target')

    expect(result).to(eq(:logged_out))
  end

  it 'converts the output to a symbol and returns when session expired' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args) { |_, opts|
              opts[:stderr].write("please login again.\n")
              raise Open4::SpawnError.new(
                  'cmd',
                  double('status', {
                      signaled?: false,
                      exitstatus: 1
                  }))
            })

    result = command.execute(target: 'target')

    expect(result).to(eq(:session_expired))
  end

  it 'converts the output to a symbol and returns when target unknown' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args) { |_, opts|
              opts[:stderr].write("error: unknown target: target\n")
              raise Open4::SpawnError.new(
                  'cmd',
                  double('status', {
                      signaled?: false,
                      exitstatus: 1
                  }))
            })

    result = command.execute(target: 'target')

    expect(result).to(eq(:unknown_target))
  end

  it 'converts the output to a symbol and returns when unknown status' do
    command = RubyFly::Commands::Status.new

    expect(Open4).to(
        receive(:spawn)
            .with('path/to/binary status ' +
                '-t=target',
                any_args) { |_, opts|
              opts[:stderr].write("error: weird error\n")
              raise Open4::SpawnError.new(
                  'cmd',
                  double('status', {
                      signaled?: false,
                      exitstatus: 1
                  }))
            })

    result = command.execute(target: 'target')

    expect(result).to(eq(:unknown_status))
  end
end
