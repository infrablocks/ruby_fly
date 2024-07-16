# frozen_string_literal: true

require 'lino'
require_relative 'base'
require_relative 'mixins/environment'
require_relative 'mixins/required_params'

module RubyFly
  module Commands
    class GetPipeline < Base
      include Mixins::Environment
      include Mixins::RequiredParams

      def configure_command(initial_builder, parameters)
        builder = super
        builder
          .with_subcommand('get-pipeline') do |sub|
          sub = with_target(sub, parameters[:target])
          sub = with_pipeline(sub, parameters[:pipeline])
          sub
        end
      end

      private

      def required_params
        %i[target pipeline]
      end

      def with_target(sub, target)
        sub.with_option('-t', target)
      end

      def with_pipeline(sub, pipeline)
        sub.with_option('-p', pipeline)
      end
    end
  end
end
