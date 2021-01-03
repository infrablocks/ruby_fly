require 'fileutils'

module RubyFly
  class RC
    module Conversions
      def self.symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          new_key = case key
          when String then
            key.to_sym
          else
            key
          end
          new_value = case value
          when Hash then
            symbolize_keys(value)
          else
            value
          end
          result[new_key] = new_value
          result
        }
      end

      def self.stringify_keys(hash)
        hash.inject({}) { |result, (key, value)|
          new_key = case key
          when Symbol then
            key.to_s
          else
            key
          end
          new_value = case value
          when Hash then
            stringify_keys(value)
          else
            value
          end
          result[new_key] = new_value
          result
        }
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
      attr_reader :name, :api, :team, :token
      attr_writer :api, :team, :token

      def self.clone(target, overrides = {})
        if target.nil?
          return target
        end
        Target.new(
            name: overrides[:name] || target.name,
            api: overrides[:api] || target.api,
            team: overrides[:team] || target.team,
            token: overrides[:token] || target.token)
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
            value: value
        }
      end

      def bearer_token
        @token[:type] == 'bearer' ?
            @token[:value] :
            nil
      end

      def encode_with(coder)
        coder.represent_map(
            nil,
            RubyFly::RC::Conversions.stringify_keys({
                api: @api,
                team: @team.to_s,
                token: @token
            }))
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
      home = options[:home] || ENV['HOME']
      name = options[:name] || '.flyrc'
      path = File.join(home, name)

      contents = options[:contents] ||
          (File.exist?(path) ?
              RubyFly::RC::Conversions.symbolize_keys(YAML.load_file(path)) :
              {})
      targets = File.exist?(path) ?
          contents[:targets].map { |n, t| Target.new(t.merge(name: n)) } :
          []

      RubyFly::RC.new(
          home: home,
          name: name,
          targets: targets)
    end

    def initialize(options)
      @home = options[:home] || ENV['HOME']
      @name = options[:name] || '.flyrc'
      @targets = options[:targets].inject({}) do |acc, target|
        acc.merge(target.name => target)
      end
    end

    def targets
      @targets.values
    end

    def find_target(target_name)
      Target.clone(@targets[target_name.to_sym])
    end

    def has_target?(target_name)
      @targets.has_key?(target_name)
    end

    def add_target(target)
      if has_target?(target.name)
        raise TargetAlreadyPresentError.new(target.name)
      end
      @targets[target.name] = target
    end

    def update_target(target_name, &block)
      unless has_target?(target_name)
        raise TargetNotPresentError.new(target_name)
      end
      mutable_target = find_target(target_name)
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
      unless has_target?(target_name)
        raise TargetNotPresentError.new(target_name)
      end
      @targets.delete(target_name)
    end

    def to_yaml
      RubyFly::RC::Conversions
          .stringify_keys({targets: @targets})
          .to_yaml
    end

    def write!
      FileUtils.mkdir_p(@home)
      File.open(File.join(@home, @name), 'w') do |file|
        file.write(to_yaml)
      end
    end
  end
end