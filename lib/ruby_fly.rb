# frozen_string_literal: true

require 'ruby_fly/version'
require 'ruby_fly/commands'
require 'ruby_fly/rc'

module RubyFly
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @configuration = nil
    end
  end

  module ClassMethods
    def login(opts = {})
      Commands::Login.new.execute(opts)
    end

    def status(opts = {})
      Commands::Status.new.execute(opts)
    end

    def get_pipeline(opts = {})
      Commands::GetPipeline.new.execute(opts)
    end

    # rubocop:disable Naming/AccessorMethodName
    def set_pipeline(opts = {})
      Commands::SetPipeline.new.execute(opts)
    end
    # rubocop:enable Naming/AccessorMethodName

    def unpause_pipeline(opts = {})
      Commands::UnpausePipeline.new.execute(opts)
    end

    def destroy_pipeline(opts = {})
      Commands::DestroyPipeline.new.execute(opts)
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
    attr_accessor :binary, :stdin, :stdout, :stderr

    def initialize
      @binary = 'fly'
      @stdin = ''
      @stdout = $stdout
      @stderr = $stderr
    end
  end
end
