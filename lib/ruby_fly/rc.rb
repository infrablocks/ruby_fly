# frozen_string_literal: true

require 'fileutils'

module RubyFly
  class RC
    module Conversions
      def self.symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), result|
          new_key = key.is_a?(String) ? key.to_sym : key
          new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
          result[new_key] = new_value
        end
      end

      def self.stringify_keys(hash)
        hash.each_with_object({}) do |(key, value), result|
          new_key = key.is_a?(Symbol) ? key.to_s : key
          new_value = value.is_a?(Hash) ? stringify_keys(value) : value
          result[new_key] = new_value
        end
      end
    end

    class TargetAlreadyPresentError < StandardError
      def initialize(target_name)
        super("Target with name: #{target_name} already present in RC.")
      end
    end

    class TargetNotPresentError < StandardError
      def initialize(target_name)
        super("Target with name: #{target_name} not present in RC.")
      end
    end

    class Target
      attr_accessor :api, :team, :token
      attr_reader :name

      def self.clone(target, overrides = {})
        return target if target.nil?

        Target.new(
          name: overrides[:name] || target.name,
          api: overrides[:api] || target.api,
          team: overrides[:team] || target.team,
          token: overrides[:token] || target.token
        )
      end

      def initialize(parameters)
        @name = parameters[:name]
        @api = parameters[:api]
        @team = parameters[:team]
        @token = parameters[:token]
      end

      def bearer_token=(value)
        @token = {
          type: 'bearer',
          value:
        }
      end

      def bearer_token
        @token[:value] if @token[:type] == 'bearer'
      end

      def encode_with(coder)
        coder.represent_map(
          nil,
          RubyFly::RC::Conversions.stringify_keys(
            { api: @api, team: @team.to_s, token: @token }
          )
        )
      end

      def ==(other)
        other.class == self.class && other.state == state
      end

      def eql?(other)
        self == other
      end

      def hash
        state.hash
      end

      protected

      def state
        [@name, @api, @team, @token]
      end
    end

    def self.load(options)
      home = options[:home] || Dir.home
      name = options[:name] || '.flyrc'
      path = File.join(home, name)

      contents = options[:contents] || try_load_rc_file_contents(path) || {}
      targets = try_load_rc_file_targets(path, contents) || []

      RubyFly::RC.new(home:, name:, targets:)
    end

    class << self
      private

      def rc_file_exists?(path)
        File.exist?(path)
      end

      def try_load_rc_file_contents(path)
        return unless rc_file_exists?(path)

        RubyFly::RC::Conversions.symbolize_keys(YAML.load_file(path))
      end

      def try_load_rc_file_targets(path, contents)
        return unless rc_file_exists?(path)

        contents[:targets].map { |n, t| Target.new(t.merge(name: n)) }
      end
    end

    def initialize(options)
      @home = options[:home] || Dir.home
      @name = options[:name] || '.flyrc'
      @targets = options[:targets].inject({}) do |acc, target|
        acc.merge(target.name => target)
      end
    end

    def targets
      @targets.values
    end

    def target?(target_name)
      @targets.key?(target_name)
    end

    def find_target(target_name)
      Target.clone(@targets[target_name.to_sym])
    end

    def add_target(target)
      raise TargetAlreadyPresentError, target.name if target?(target.name)

      @targets[target.name] = target
    end

    def update_target(target_name, &block)
      raise TargetNotPresentError, target_name unless target?(target_name)

      mutable_target = find_target(target_name)
      block.call(mutable_target)
      updated_target = Target.clone(mutable_target, name: target_name)
      @targets[target_name] = updated_target
    end

    def add_or_update_target(target_name, &block)
      mutable_target = if target?(target_name)
                         find_target(target_name)
                       else
                         Target.new({ name: target_name })
                       end
      block.call(mutable_target)
      updated_target = Target.clone(mutable_target, name: target_name)
      @targets[target_name] = updated_target
    end

    def rename_target(old_target_name, new_target_name)
      old_target = find_target(old_target_name)
      new_target = Target.clone(old_target, name: new_target_name)
      remove_target(old_target_name)
      add_target(new_target)
    end

    def remove_target(target_name)
      raise TargetNotPresentError, target_name unless target?(target_name)

      @targets.delete(target_name)
    end

    def to_yaml
      RubyFly::RC::Conversions
        .stringify_keys({ targets: @targets })
        .to_yaml
    end

    def write!
      FileUtils.mkdir_p(@home)
      File.write(File.join(@home, @name), to_yaml)
    end
  end
end
