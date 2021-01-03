require 'faker'

module Build
  module Data
    def self.random_concourse_url
      Faker::Internet.url
    end

    def self.random_team_name
      Faker::Lorem.unique.word.to_sym
    end

    def self.random_access_token
      Faker::Alphanumeric.alphanumeric(number: 38)
    end

    def self.random_token(overrides = {})
      {
          type: 'bearer',
          value: self.random_access_token
      }.merge(overrides)
    end

    def self.random_target_name
      Faker::Lorem.unique.word.to_sym
    end

    def self.random_target_data(overrides = {})
      {
          api: self.random_concourse_url,
          team: self.random_team_name,
          token: self.random_token
      }.merge(overrides)
    end

    def self.random_target(overrides = {})
      RubyFly::RC::Target.new(
          self.random_target_data
              .merge(name: self.random_target_name)
              .merge(overrides))
    end
  end
end