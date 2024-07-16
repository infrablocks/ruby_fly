# frozen_string_literal: true

require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class Version < Base
      private

      def invocation_option_defaults(_invocation_options)
        super.merge(capture: [:stdout])
      end

      def configure_command(initial_builder, _parameters)
        builder = super
        builder.with_flag('--version')
      end

      def process_result(result, _parameters, _invocation_options)
        output = result[:output]
        output.gsub("\n", '')
      end
    end
  end
end
