# frozen_string_literal: true

require 'lino'
require_relative 'base'

module RubyFly
  module Commands
    class Version < Base
      def stdout
        @version_string
      end

      def do_before(_opts)
        @version_string = StringIO.new
      end

      def configure_command(builder, _opts)
        builder.with_flag('--version')
      end

      def do_after(_opts)
        @version_string.string.gsub(/\n/, '')
      end
    end
  end
end
