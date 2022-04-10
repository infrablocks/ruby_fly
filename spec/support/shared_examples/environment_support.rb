# frozen_string_literal: true

shared_examples(
  'a command with environment support'
) do |command_name, arguments = [], options = {}, binary = nil|
  let(:arguments_string) do
    arguments.empty? ? '' : " #{arguments.join(' ')}"
  end

  let(:command_string) { "#{command_name}#{arguments_string}" }
  let(:binary) { binary || 'fly' }

  it 'uses the environment provided at execution' do
    command = described_class.new

    allow(Open4).to(receive(:spawn))

    command.execute(
      options.merge(environment: [
                      %w[THING1 thing1],
                      %w[THING2 thing2]
                    ])
    )

    expect(Open4)
      .to(have_received(:spawn)
        .with(
          /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/,
          any_args
        ))
  end

  it 'uses the environment previously configured' do
    command = described_class.new
                             .for_environment([
                                                %w[THING1 thing1],
                                                %w[THING2 thing2]
                                              ])

    allow(Open4).to(receive(:spawn))

    command.execute(options)

    expect(Open4)
      .to(have_received(:spawn)
        .with(
          /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/,
          any_args
        ))
  end

  it 'prefers the environment passed at execution time over that previously ' \
     'configured' do
    command = described_class.new
                             .for_environment([
                                                %w[THING1 thing1],
                                                %w[THING2 thing2]
                                              ])

    allow(Open4).to(receive(:spawn))

    command.execute(options.merge(environment: [
                                    %w[THING3 thing3],
                                    %w[THING4 thing4]
                                  ]))

    expect(Open4)
      .to(have_received(:spawn)
        .with(
          /^THING3="thing3" THING4="thing4" #{binary} .*#{command_string}$/,
          any_args
        ))
  end
end
