# frozen_string_literal: true

require 'lino'
require_relative 'base'
require_relative 'mixins/environment'
require_relative 'mixins/required_params'

module RubyFly
  module Commands
    class SetPipeline < Base
      include Mixins::Environment
      include Mixins::RequiredParams

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def configure_command(initial_builder, parameters)
        builder = super
        builder
          .with_subcommand('set-pipeline') do |sub|
            sub = with_target(sub, parameters[:target])
            sub = with_pipeline(sub, parameters[:pipeline])
            sub = with_config(sub, parameters[:config])
            sub = with_team(sub, parameters[:team])
            sub = with_vars(sub, parameters[:vars])
            sub = with_var_files(sub, parameters[:var_files])
            sub = with_non_interactive(sub, parameters[:non_interactive])
            sub
          end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      private

      def required_params
        %i[target pipeline config]
      end

      def with_target(sub, target)
        sub.with_option('-t', target)
      end

      def with_pipeline(sub, pipeline)
        sub.with_option('-p', pipeline)
      end

      def with_config(sub, config)
        sub.with_option('-c', config)
      end

      def with_team(sub, team)
        return sub unless team

        sub.with_option('--team', team)
      end

      def with_vars(builder, vars)
        vars ||= {}
        vars.each do |key, value|
          builder = builder.with_option('-v', "'#{key}=#{value}'")
        end
        builder
      end

      def with_var_files(builder, var_files)
        var_files ||= []
        var_files.each do |var_file|
          builder = builder.with_option('-l', var_file)
        end
        builder
      end

      def with_non_interactive(builder, non_interactive)
        return builder unless non_interactive

        builder.with_flag('-n')
      end
    end
  end
end
