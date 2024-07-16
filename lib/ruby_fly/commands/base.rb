# frozen_string_literal: true

require 'lino'
require 'tempfile'

module RubyFly
  module Commands
    class Base
      def initialize(parameters = {})
        @binary = parameters[:binary] || RubyFly.configuration.binary
        @stdin = stdin || RubyFly.configuration.stdin
        @stdout = stdout || RubyFly.configuration.stdout
        @stderr = stderr || RubyFly.configuration.stderr
      end

      def execute(parameters = {}, invocation_options = {})
        parameters = resolve_parameters(parameters)
        invocation_options = resolve_invocation_options(invocation_options)

        do_before(parameters, invocation_options)
        result = do_around(parameters, invocation_options) do |p, io|
          build_and_execute_command(p, io)
        end
        result = do_after(result, parameters, invocation_options)
        prepare_result(result, parameters, invocation_options)
      end

      private

      attr_reader :binary, :stdin, :stdout, :stderr

      def do_before(parameters, invocation_options); end

      def do_around(parameters, invocation_options)
        yield parameters, invocation_options
      end

      def do_after(result, _parameters, _invocation_options)
        result
      end

      def build_and_execute_command(parameters, invocation_options)
        command = configure_command(instantiate_builder, parameters).build
        stdout = resolve_stdout(invocation_options)
        stderr = resolve_stderr(invocation_options)
        begin
          command.execute(stdin:, stdout:, stderr:)
        rescue Lino::Errors::ExecutionError => e
          raise e unless e.exit_code == 1
        end
        process_streams(invocation_options, stdout, stderr)
      end

      def instantiate_builder
        Lino.builder_for_command(binary)
            .with_option_separator('=')
      end

      def configure_command(builder, _parameters)
        builder
      end

      def process_result(result, _parameters, _invocation_options)
        result
      end

      def parameter_defaults(_parameters)
        {}
      end

      def parameter_overrides(_parameters)
        {}
      end

      def invocation_option_defaults(_invocation_options)
        { capture: [], result: :processed }
      end

      def resolve_parameters(parameters)
        parameter_defaults(parameters)
          .merge(parameters)
          .merge(parameter_overrides(parameters))
      end

      def resolve_invocation_options(invocation_options)
        invocation_option_defaults(invocation_options)
          .merge(invocation_options)
      end

      def resolve_stdout(invocation_options)
        invocation_options[:capture].include?(:stdout) ? Tempfile.new : @stdout
      end

      def resolve_stderr(invocation_options)
        invocation_options[:capture].include?(:stderr) ? Tempfile.new : @stderr
      end

      def process_streams(invocation_options, stdout, stderr)
        cap = invocation_options[:capture]
        result = {}
        add_contents_to_result(cap, result, :stdout, stdout, :output)
        add_contents_to_result(cap, result, :stderr, stderr, :error)
        result
      end

      def add_contents_to_result(capture, result, stream_name, stream, type)
        return unless capture.include?(stream_name)

        stream.rewind
        result[type] = stream.read
      end

      def prepare_result(result, parameters, invocation_options)
        return result if invocation_options[:result] == :raw

        process_result(result, parameters, invocation_options)
      end
    end
  end
end
