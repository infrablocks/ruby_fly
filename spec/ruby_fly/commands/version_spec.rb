# frozen_string_literal: true

require 'spec_helper'

describe RubyFly::Commands::Version do
  let(:executor) { Lino::Executors::Mock.new }

  before do
    Lino.configure do |config|
      config.executor = executor
    end
  end

  after do
    Lino.reset!
  end

  it 'calls the fly command passing the version flag' do
    command = described_class.new(binary: 'fly')

    command.execute

    expect(executor.executions.first.command_line.string)
      .to(eq('fly --version'))
  end
end
