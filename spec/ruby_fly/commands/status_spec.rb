# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Status do
  before do
    RubyFly.configure do |config|
      config.binary = 'path/to/binary'
    end
  end

  after do
    RubyFly.reset!
  end

  it 'calls the fly status command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    allow(Open4).to(receive(:spawn))

    command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('fly status -t=target', any_args))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
  end

  it_behaves_like(
    'a command with environment support',
    'status',
    ['-t=target'],
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

  # rubocop:disable RSpec/MultipleExpectations
  it 'converts the output to a symbol and returns when logged in' do
    command = described_class.new

    allow(Open4).to(receive(:spawn) do |_, opts|
      opts[:stdout].write("logged in successfully\n")
    end)

    result = command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
    expect(result).to(eq(:logged_in))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'converts the output to a symbol and returns when logged out' do
    command = described_class.new

    status = instance_double(
      'status', {
        signaled?: false,
        exitstatus: 1
      }
    )

    allow(Open4).to(receive(:spawn) do |_, opts|
      opts[:stderr].write("logged out\n")
      raise Open4::SpawnError.new('cmd', status)
    end)

    result = command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
    expect(result).to(eq(:logged_out))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'converts the output to a symbol and returns when session expired' do
    command = described_class.new

    status = instance_double(
      'status', {
        signaled?: false,
        exitstatus: 1
      }
    )

    allow(Open4).to(receive(:spawn) do |_, opts|
      opts[:stderr].write("please login again.\n")
      raise Open4::SpawnError.new('cmd', status)
    end)

    result = command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
    expect(result).to(eq(:session_expired))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'converts the output to a symbol and returns when target unknown' do
    command = described_class.new

    status = instance_double(
      'status', {
        signaled?: false,
        exitstatus: 1
      }
    )

    allow(Open4).to(receive(:spawn) do |_, opts|
      opts[:stderr].write("error: unknown target: target\n")
      raise Open4::SpawnError.new('cmd', status)
    end)

    result = command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
    expect(result).to(eq(:unknown_target))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'converts the output to a symbol and returns when unknown status' do
    command = described_class.new

    status = instance_double(
      'status', {
        signaled?: false,
        exitstatus: 1
      }
    )

    allow(Open4).to(receive(:spawn) do |_, opts|
      opts[:stderr].write("error: weird error\n")
      raise Open4::SpawnError.new('cmd', status)
    end)

    result = command.execute(target: 'target')

    expect(Open4)
      .to(have_received(:spawn)
            .with('path/to/binary status -t=target', any_args))
    expect(result).to(eq(:unknown_status))
  end
  # rubocop:enable RSpec/MultipleExpectations
end
