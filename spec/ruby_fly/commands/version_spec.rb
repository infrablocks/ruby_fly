# frozen_string_literal: true

require 'spec_helper'

describe RubyFly::Commands::Version do
  it 'calls the fly command passing the version flag' do
    command = described_class.new(binary: 'fly')

    allow(Open4).to(receive(:spawn))

    command.execute

    expect(Open4)
      .to(have_received(:spawn)
            .with('fly --version', any_args))
  end
end
