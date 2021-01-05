shared_examples(
    "a command with environment support"
) do |command_name, arguments = [], options = {}, binary = nil|
  let(:arguments_string) do
    arguments.empty? ? "" : " #{arguments.join(" ")}"
  end

  let(:command_string) { "#{command_name}#{arguments_string}" }
  let(:binary) { binary || "fly" }

  it 'uses the environment provided at execution' do
    command = subject.class.new

    expect(Open4).to(
        receive(:spawn)
            .with(
                /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/,
                any_args))

    command.execute(
        options.merge(environment: [
            ["THING1", "thing1"],
            ["THING2", "thing2"]
        ]))
  end

  it 'uses the environment previously configured' do
    command = subject.class.new
        .for_environment([
            ["THING1", "thing1"],
            ["THING2", "thing2"]
        ])

    expect(Open4).to(
        receive(:spawn)
            .with(
                /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/,
                any_args))

    command.execute(options)
  end

  it 'prefers the environment passed at execution time over that previously ' +
      'configured' do
    command = subject.class.new
        .for_environment([
            ["THING1", "thing1"],
            ["THING2", "thing2"]
        ])

    expect(Open4).to(
        receive(:spawn)
            .with(
                /^THING3="thing3" THING4="thing4" #{binary} .*#{command_string}$/,
                any_args))

    command.execute(options.merge(environment: [
        ["THING3", "thing3"],
        ["THING4", "thing4"]
    ]))
  end
end
