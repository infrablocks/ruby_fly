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

      private

      def invocation_option_defaults(_invocation_options)
        super.merge(capture: %i[stdout stderr])
      end

      def configure_command(initial_builder, parameters)
        builder = super
        builder
          .with_subcommand('status') do |sub|
          sub = with_target(sub, parameters[:target])
          sub
        end
      end

      def do_around(parameters, invocation_options, &block)
        block.call(parameters, invocation_options)
      end

      def process_result(result, _parameters, _invocation_options)
        output = result[:output]
        error = result[:error]

        return :logged_in if output =~ /logged in successfully/
        return :logged_out if error =~ /logged out/
        return :session_expired if error =~ /please login again/
        return :unknown_target if error =~ /error: unknown target/

        :unknown_status
      end

      def required_params
        %i[target]
      end

      def with_target(sub, target)
        sub.with_option('-t', target)
      end
    end
  end
end
