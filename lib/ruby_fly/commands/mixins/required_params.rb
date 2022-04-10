# frozen_string_literal: true

module RubyFly
  module Commands
    module Mixins
      module RequiredParams
        def configure_command(builder, opts)
          assert_required_params(opts)
          super(builder, opts)
        end

        def required_params
          %i[]
        end

        private

        def missing_params(opts)
          required_params.select { |param| opts[param].nil? }
        end

        def assert_required_params(opts)
          missing_params = missing_params(opts)
          return if missing_params.empty?

          description = missing_params.map { |p| "'#{p}'" }.join(', ')
          raise(
            ArgumentError,
            "Error: #{description} required but not provided."
          )
        end
      end
    end
  end
end
