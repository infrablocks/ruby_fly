require 'lino'
require_relative 'base'
require_relative 'mixins/environment'

module RubyFly
  module Commands
    class Status < Base
      include Mixins::Environment

      def initialize(*args)
        super(*args)
        @stdout = StringIO.new unless
            (defined?(@stdout) && @stdout.respond_to?(:string))
        @stderr = StringIO.new unless
            (defined?(@stderr) && @stderr.respond_to?(:string))
      end

      def configure_command(builder, opts)
        builder = super(builder, opts)

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

        builder
          .with_subcommand('status') do |sub|
            sub = sub.with_option('-t', target)
            sub
          end
      end

      def do_after(opts)
        output = stdout.string
        error = stderr.string

        return :logged_in if output =~ /logged in successfully/
        return :logged_out if error =~ /logged out/
        return :session_expired if error =~ /please login again/
        return :unknown_target if error =~ /error: unknown target/

        :unknown_status
      end
    end
  end
end