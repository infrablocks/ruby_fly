require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class UnpausePipeline < Base
      def configure_command(builder, opts)
        missing_params = [
            :target,
            :pipeline
        ].select { |param| opts[param].nil? }

        unless missing_params.empty?
          description = missing_params.map { |p| "'#{p}'" }.join(', ')
          raise(
              ArgumentError,
              "Error: #{description} required but not provided.")
        end

        target = opts[:target]
        pipeline = opts[:pipeline]
        team = opts[:team]

        builder
            .with_subcommand('unpause-pipeline') do |sub|
              sub = sub.with_option('-t', target)
              sub = sub.with_option('-p', pipeline)
              sub = sub.with_option('--team', team) if team
              sub
            end
      end
    end
  end
end