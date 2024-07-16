# frozen_string_literal: true

require 'lino'
require_relative 'base'
require_relative 'mixins/environment'
require_relative 'mixins/required_params'

module RubyFly
  module Commands
    class Login < Base
      include Mixins::Environment
      include Mixins::RequiredParams

      def configure_command(initial_builder, parameters)
        builder = super
        builder
          .with_subcommand('login') do |sub|
            sub = with_target(sub, parameters[:target])
            sub = with_concourse_url(sub, parameters[:concourse_url])
            sub = with_username(sub, parameters[:username])
            sub = with_password(sub, parameters[:password])
            sub = with_team(sub, parameters[:team])
            sub
          end
      end

      private

      def required_params
        %i[target]
      end

      def with_target(builder, target)
        builder.with_option('-t', target)
      end

      def with_concourse_url(builder, concourse_url)
        return builder unless concourse_url

        builder.with_option('-c', concourse_url)
      end

      def with_username(builder, username)
        return builder unless username

        builder.with_option('-u', username)
      end

      def with_password(builder, password)
        return builder unless password

        builder.with_option('-p', password)
      end

      def with_team(builder, team)
        return builder unless team

        builder.with_option('-n', team)
      end
    end
  end
end
