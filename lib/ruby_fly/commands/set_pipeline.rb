require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class SetPipeline < Base
      def configure_command(builder, opts)
        missing_params = [
            :target,
            :pipeline,
            :config
        ].select { |param| opts[param].nil? }

        unless missing_params.empty?
          description = missing_params.map { |p| "'#{p}'" }.join(', ')
          raise(
              ArgumentError,
              "Error: #{description} required but not provided.")
        end

        target = opts[:target]
        pipeline = opts[:pipeline]
        config = opts[:config]
        vars = opts[:vars] || {}
        var_files = opts[:var_files] || []
        non_interactive = opts[:non_interactive]
        team = opts[:team]

        builder
          .with_subcommand('set-pipeline') do |sub|
            sub = sub.with_option('-t', target)
            sub = sub.with_option('-p', pipeline)
            sub = sub.with_option('-c', config)
            sub = sub.with_option('--team', team) if team
            vars.each do |key, value|
              sub = sub.with_option('-v', "'#{key}=#{value}'")
            end
            var_files.each do |var_file|
              sub = sub.with_option('-l', var_file)
            end
            sub = sub.with_flag('-n') if non_interactive
            sub
          end
      end
    end
  end
end