require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class GetPipeline < Base
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

        builder
            .with_subcommand('get-pipeline') do |sub|
              sub = sub.with_option('-t', target)
              sub = sub.with_option('-p', pipeline)
              sub
            end
      end
    end
  end
end