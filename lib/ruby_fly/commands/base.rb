# frozen_string_literal: true

require 'lino'

module RubyFly
  module Commands
    class Base
      attr_reader :binary, :stdin, :stdout, :stderr

      def initialize(opts = {})
        @binary = opts[:binary] || RubyFly.configuration.binary
        @stdin = stdin || RubyFly.configuration.stdin
        @stdout = stdout || RubyFly.configuration.stdout
        @stderr = stderr || RubyFly.configuration.stderr
      end

      def execute(opts = {})
        do_before(opts)
        do_around(opts) do |new_opts|
          configure_command(instantiate_builder, new_opts)
            .build
            .execute(stdin: stdin, stdout: stdout, stderr: stderr)
        end
        do_after(opts)
      end

      def instantiate_builder
        Lino::CommandLineBuilder
          .for_command(binary)
          .with_option_separator('=')
      end

      def do_before(opts); end

      def do_around(opts, &block)
        block.call(opts)
      end

      def configure_command(builder, _opts)
        builder
      end

      def do_after(opts); end
    end
  end
end
