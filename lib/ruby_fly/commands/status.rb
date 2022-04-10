# frozen_string_literal: true

require 'lino'
require_relative 'base'
require_relative 'mixins/environment'
require_relative 'mixins/required_params'

module RubyFly
  module Commands
    class Status < Base
      include Mixins::Environment
      include Mixins::RequiredParams

      def initialize(*args)
        super(*args)
        @stdout = StringIO.new unless
            defined?(@stdout) && @stdout.respond_to?(:string)
        @stderr = StringIO.new unless
            defined?(@stderr) && @stderr.respond_to?(:string)
      end

      def configure_command(builder, opts)
        builder = super(builder, opts)
        builder
          .with_subcommand('status') do |sub|
            sub = with_target(sub, opts[:target])
            sub
          end
      end

      def do_around(opts, &block)
        block.call(opts)
      rescue Open4::SpawnError => e
        raise e unless e.status.exitstatus == 1
      end

      def do_after(_opts)
        output = stdout.string
        error = stderr.string

        return :logged_in if output =~ /logged in successfully/
        return :logged_out if error =~ /logged out/
        return :session_expired if error =~ /please login again/
        return :unknown_target if error =~ /error: unknown target/

        :unknown_status
      end

      private

      def required_params
        %i[target]
      end

      def with_target(sub, target)
        sub.with_option('-t', target)
      end
    end
  end
end
