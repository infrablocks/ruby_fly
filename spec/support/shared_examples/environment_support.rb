# frozen_string_literal: true

shared_examples(
  'a command with environment support'
) do |command_name, arguments = [], options = {}, binary = nil|
  let(:arguments_string) { arguments.empty? ? '' : " #{arguments.join(' ')}" }
  let(:command_string) { "#{command_name}#{arguments_string}" }
  let(:binary) { binary || 'fly' }
  let(:executor) { Lino::Executors::Mock.new }

  before do
    Lino.configure do |config|
      config.executor = executor
    end
  end

  after do
    Lino.reset!
  end

  it 'uses the environment provided at execution' do
    command = described_class.new

    command.execute(
      options.merge(environment: [
                      %w[THING1 thing1],
                      %w[THING2 thing2]
                    ])
    )

    expect(executor.executions.first.command_line.string)
      .to(match(
            /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/
          ))
  end

  it 'uses the environment previously configured' do
    command = described_class.new
                             .for_environment([
                                                %w[THING1 thing1],
                                                %w[THING2 thing2]
                                              ])

    command.execute(options)

    expect(executor.executions.first.command_line.string)
      .to(match(
            /^THING1="thing1" THING2="thing2" #{binary} .*#{command_string}$/
          ))
  end

  it 'prefers the environment passed at execution time over that previously ' \
     'configured' do
    command = described_class.new
                             .for_environment([
                                                %w[THING1 thing1],
                                                %w[THING2 thing2]
                                              ])

    command.execute(options.merge(environment: [
                                    %w[THING3 thing3],
                                    %w[THING4 thing4]
                                  ]))

    expect(executor.executions.first.command_line.string)
      .to(match(
            /^THING3="thing3" THING4="thing4" #{binary} .*#{command_string}$/
          ))
  end
end
