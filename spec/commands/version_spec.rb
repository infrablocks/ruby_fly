require 'spec_helper'

describe RubyFly::Commands::Version do
  it 'calls the fly command passing the version flag' do
    command = RubyFly::Commands::Version.new(binary: 'fly')

    expect(Open4).to(
        receive(:spawn)
            .with('fly --version', any_args))

    command.execute()
  end
end
