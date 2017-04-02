require 'ruby_fly/version'
require 'ruby_fly/commands'

module RubyFly
  class << self
    attr_accessor :configuration

    def configure
      @configuration ||= Configuration.new
      yield(@configuration)
    end

    def reset!
      @configuration = nil
    end
  end

  module ClassMethods
    def get_pipeline(opts = {})
      Commands::GetPipeline.new.execute(opts)
    end

    def set_pipeline(opts = {})
      Commands::SetPipeline.new.execute(opts)
    end

    def unpause_pipeline(opts = {})
      Commands::UnpausePipeline.new.execute(opts)
    end

    def version
      Commands::Version.new.execute
    end
  end
  extend ClassMethods

  def self.included(other)
    other.extend(ClassMethods)
  end

  class Configuration
    attr_accessor :binary

    def initialize
      @binary = 'fly'
    end
  end
end
