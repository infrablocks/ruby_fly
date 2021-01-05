require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class Login < Base
      def configure_command(builder, opts)
        missing_params = [
            :target
        ].select { |param| opts[param].nil? }

        unless missing_params.empty?
          description = missing_params.map { |p| "'#{p}'" }.join(', ')
          raise(
              ArgumentError,
              "Error: #{description} required but not provided.")
        end

        target = opts[:target]
        concourse_url = opts[:concourse_url]
        username = opts[:username]
        password = opts[:password]
        team = opts[:team]

        builder
          .with_subcommand('login') do |sub|
            sub = sub.with_option('-t', target)
            sub = sub.with_option('-c', concourse_url) if concourse_url
            sub = sub.with_option('-u', username) if username
            sub = sub.with_option('-p', password) if password
            sub = sub.with_option('-n', team) if team
            sub
          end
      end
    end
  end
end