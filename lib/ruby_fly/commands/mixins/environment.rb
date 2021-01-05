module RubyFly
  module Commands
    module Mixins
      module Environment
        def initialize(opts={})
          super(opts)
          @environment = opts[:environment]
        end

        def for_environment(environment)
          @environment = environment
          self
        end

        def configure_command(builder, opts)
          builder = super(builder, opts)
          environment = opts[:environment] || @environment
          if environment
            builder = environment.to_a
                .inject(builder) do |b, environment_variable|
              b.with_environment_variable(*environment_variable)
            end
          end
          builder
        end
      end
    end
  end
end