# frozen_string_literal: true

require 'lino'
require_relative 'base'
require_relative 'mixins/environment'
require_relative 'mixins/required_params'

module RubyFly
  module Commands
    class DestroyPipeline < Base
      include Mixins::Environment
      include Mixins::RequiredParams

      private

      def configure_command(initial_builder, parameters)
        builder = super
        builder
          .with_subcommand('destroy-pipeline') do |sub|
          sub = with_target(sub, parameters[:target])
          sub = with_pipeline(sub, parameters[:pipeline])
          sub = with_team(sub, parameters[:team])
          sub = with_non_interactive(sub, parameters[:non_interactive])
          sub
        end
      end

      def required_params
        %i[target pipeline]
      end

      def with_target(sub, target)
        sub.with_option('-t', target)
      end

      def with_pipeline(sub, pipeline)
        sub.with_option('-p', pipeline)
      end

      def with_team(sub, team)
        return sub unless team

        sub.with_option('--team', team)
      end

      def with_non_interactive(sub, non_interactive)
        return sub unless non_interactive

        sub.with_flag('-n')
      end
    end
  end
end
