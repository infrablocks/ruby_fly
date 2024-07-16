# frozen_string_literal: true

require 'spec_helper'

require_relative '../../support/shared_examples/environment_support'

describe RubyFly::Commands::Status do
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

  it 'calls the fly status command passing the required arguments' do
    command = described_class.new(binary: 'fly')

    command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('fly status -t=target'))
  end

  it 'defaults to the configured binary when none provided' do
    command = described_class.new

    command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
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

    executor.write_to_stdout("logged in successfully\n")

    result = command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
    expect(result).to(eq(:logged_in))
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  # rubocop:disable RSpec/VerifiedDoubleReference
  it 'converts the output to a symbol and returns when logged out' do
    command = described_class.new

    instance_double(
      'signal', {
        signaled?: false,
        exitstatus: 1
      }
    )

    executor.write_to_stderr("logged out\n")
    executor.fail_all_executions

    result = command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
    expect(result).to(eq(:logged_out))
  end
  # rubocop:enable RSpec/VerifiedDoubleReference
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  # rubocop:disable RSpec/VerifiedDoubleReference
  it 'converts the output to a symbol and returns when session expired' do
    command = described_class.new

    instance_double(
      'signal', {
        signaled?: false,
        exitstatus: 1
      }
    )

    executor.write_to_stderr("please login again.\n")
    executor.fail_all_executions

    result = command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
    expect(result).to(eq(:session_expired))
  end
  # rubocop:enable RSpec/VerifiedDoubleReference
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  # rubocop:disable RSpec/VerifiedDoubleReference
  it 'converts the output to a symbol and returns when target unknown' do
    command = described_class.new

    instance_double(
      'signal', {
        signaled?: false,
        exitstatus: 1
      }
    )

    executor.write_to_stderr("error: unknown target: target\n")
    executor.fail_all_executions

    result = command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
    expect(result).to(eq(:unknown_target))
  end
  # rubocop:enable RSpec/VerifiedDoubleReference
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  # rubocop:disable RSpec/VerifiedDoubleReference
  it 'converts the output to a symbol and returns when unknown status' do
    command = described_class.new

    instance_double(
      'signal', {
        signaled?: false,
        exitstatus: 1
      }
    )

    executor.write_to_stderr("error: weird error\n")
    executor.fail_all_executions

    result = command.execute(target: 'target')

    expect(executor.executions.first.command_line.string)
      .to(eq('path/to/binary status -t=target'))
    expect(result).to(eq(:unknown_status))
  end
  # rubocop:enable RSpec/VerifiedDoubleReference
  # rubocop:enable RSpec/MultipleExpectations
end
