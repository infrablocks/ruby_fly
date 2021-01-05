require 'lino'

module RubyFly
  module Commands
    class Base
      attr_reader :binary, :stdin, :stdout, :stderr

      def initialize(binary: nil)
        @binary = binary || RubyFly.configuration.binary
        @stdin = stdin || RubyFly.configuration.stdin
        @stdout = stdout || RubyFly.configuration.stdout
        @stderr = stderr || RubyFly.configuration.stderr
      end

      def execute(opts = {})
        builder = instantiate_builder

        do_before(opts)
        configure_command(builder, opts)
            .build
            .execute(
                stdin: stdin,
                stdout: stdout,
                stderr: stderr)
        do_after(opts)
      end

      def instantiate_builder
        Lino::CommandLineBuilder
            .for_command(binary)
            .with_option_separator('=')
      end

      def do_before(opts)
      end

      def configure_command(builder, opts)
        builder
      end

      def do_after(opts)
      end
    end
  end
end