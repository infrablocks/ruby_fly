# frozen_string_literal: true

module RubyFly
  module Commands
    module Mixins
      module RequiredParams
        def configure_command(initial_builder, parameters)
          assert_required_params(parameters)
          super
        end

        def required_params
          %i[]
        end

        private

        def missing_params(parameters)
          required_params.select { |param| parameters[param].nil? }
        end

        def assert_required_params(parameters)
          missing_params = missing_params(parameters)
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
