# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'yaml'
require 'fileutils'

RSpec.describe RubyFly::RC do
  include FakeFS::SpecHelpers

  describe 'on load' do
    it 'reads the contents of the RC file when it exists' do
      fly_home_dir = '/some/home'

      target_name = Build::Data.random_target_name
      target_data = Build::Data.random_target_data
      targets_data = { target_name => target_data }
      contents = { targets: targets_data }

      FileUtils.mkdir_p(fly_home_dir)
      File.write("#{fly_home_dir}/.flyrc", contents.to_yaml)

      rc = described_class.load(home: fly_home_dir)

      expect(rc.targets)
        .to(eq([RubyFly::RC::Target.new(target_data.merge(name: target_name))]))
    end

    it 'creates a new RC when RC file does not exist' do
      fly_home_dir = '/some/home'

      FileUtils.mkdir_p(fly_home_dir)

      rc = described_class.load(home: fly_home_dir)

      expect(rc.targets).to(be_empty)
    end
  end

  describe 'on manipulation' do
    describe '#find_target' do
      it 'finds the named target in the RC when it exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        target = rc.find_target(target1_name)

        expect(target).to(eq(target1))
      end

      it 'return nil when the named target does not exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name
        target3_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        target = rc.find_target(target3_name)

        expect(target).to(be_nil)
      end
    end

    describe '#add_target' do
      it 'adds the target to the RC when it does not already exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1])
        rc.add_target(target2)

        expect(rc.find_target(target2_name)).to(eq(target2))
      end

      it 'throws an exception when the target already exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        expect do
          rc.add_target(target2)
        end.to(raise_error(
                 RubyFly::RC::TargetAlreadyPresentError,
                 "Target with name: #{target2_name} already present in RC."
               ))
      end
    end

    describe '#update_target' do
      it 'uses the provided block to update the target when it exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        access_token = Build::Data.random_access_token

        rc = described_class.new(targets: [target1, target2])
        rc.update_target(target2_name) do |target|
          target.api = 'https://concourse.example.com'
          target.team = :other_team
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target2_name)

        expect(updated_target)
          .to(eq(
                RubyFly::RC::Target.new(
                  name: target2_name,
                  api: 'https://concourse.example.com',
                  team: :other_team,
                  token: {
                    type: 'bearer',
                    value: access_token
                  }
                )
              ))
      end

      it 'throws an exception when the target does not exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name
        target3_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        expect do
          rc.update_target(target3_name) do |target|
            target.token = {
              type: 'bearer',
              value: Build::Data.random_access_token
            }
          end
        end.to(raise_error(
                 RubyFly::RC::TargetNotPresentError,
                 "Target with name: #{target3_name} not present in RC."
               ))
      end
    end

    describe '#add_or_update_target' do
      it 'uses the provided block to add the target when it does not exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)

        access_token = Build::Data.random_access_token

        rc = described_class.new(targets: [target1])
        rc.add_or_update_target(target2_name) do |target|
          target.api = 'https://concourse.example.com'
          target.team = :other_team
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target2_name)

        expect(updated_target)
          .to(eq(
                RubyFly::RC::Target.new(
                  name: target2_name,
                  api: 'https://concourse.example.com',
                  team: :other_team,
                  token: {
                    type: 'bearer',
                    value: access_token
                  }
                )
              ))
      end

      it 'uses the provided block to update the target when it exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        access_token = Build::Data.random_access_token

        rc = described_class.new(targets: [target1, target2])
        rc.add_or_update_target(target2_name) do |target|
          target.api = 'https://concourse.example.com'
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target2_name)

        expect(updated_target)
          .to(eq(
                RubyFly::RC::Target.new(
                  name: target2_name,
                  api: 'https://concourse.example.com',
                  team: target2.team,
                  token: {
                    type: 'bearer',
                    value: access_token
                  }
                )
              ))
      end
    end

    describe '#rename_target' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'renames the specified target when it exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        target2_new_name = Build::Data.random_target_name

        rc = described_class.new(targets: [target1, target2])
        rc.rename_target(target2_name, target2_new_name)

        expect(rc.find_target(target2_name)).to(be_nil)
        expect(rc.find_target(target2_new_name))
          .to(eq(
                RubyFly::RC::Target.clone(
                  target2, name: target2_new_name
                )
              ))
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'throws an exception when the target does not exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name
        target3_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        expect do
          rc.rename_target(target3_name, Build::Data.random_target_name)
        end.to(raise_error(
                 RubyFly::RC::TargetNotPresentError,
                 "Target with name: #{target3_name} not present in RC."
               ))
      end
    end

    describe '#remove_target' do
      it 'removes the target from the RC when it exists' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])
        rc.remove_target(target2_name)

        expect(rc.find_target(target2_name)).to(be_nil)
      end

      it 'throws an exception when the target does not exist' do
        target1_name = Build::Data.random_target_name
        target2_name = Build::Data.random_target_name
        target3_name = Build::Data.random_target_name

        target1 = Build::Data.random_target(name: target1_name)
        target2 = Build::Data.random_target(name: target2_name)

        rc = described_class.new(targets: [target1, target2])

        expect do
          rc.remove_target(target3_name)
        end.to(raise_error(
                 RubyFly::RC::TargetNotPresentError,
                 "Target with name: #{target3_name} not present in RC."
               ))
      end
    end
  end

  describe 'on write' do
    it 'writes itself to the specified path when the file does not exist' do
      fly_home_dir = '/some/home'

      FileUtils.mkdir_p(fly_home_dir)

      target1 = Build::Data.random_target
      target2 = Build::Data.random_target

      rc = described_class.new(
        home: fly_home_dir,
        targets: [target1, target2]
      )
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents)
        .to(eq({
                 'targets' => {
                   target1.name.to_s => {
                     'api' => target1.api,
                     'team' => target1.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target1.bearer_token
                     }
                   },
                   target2.name.to_s => {
                     'api' => target2.api,
                     'team' => target2.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target2.bearer_token
                     }
                   }
                 }
               }))
    end

    it 'overwrites the specified path when the file exists' do
      fly_home_dir = '/some/home'

      target1_name = Build::Data.random_target_name
      target1_data = Build::Data.random_target_data
      target2_name = Build::Data.random_target_name
      target2_data = Build::Data.random_target_data

      target1 = RubyFly::RC::Target.new(
        target1_data.merge(name: target1_name)
      )
      target2 = RubyFly::RC::Target.new(
        target2_data.merge(name: target2_name)
      )

      targets_data = { target1_name => target1_data }

      contents = { targets: targets_data }

      FileUtils.mkdir_p(fly_home_dir)
      File.write("#{fly_home_dir}/.flyrc", contents.to_yaml)

      rc = described_class.load(home: fly_home_dir)
      rc.add_target(target2)
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents)
        .to(eq({
                 'targets' => {
                   target1.name.to_s => {
                     'api' => target1.api,
                     'team' => target1.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target1.bearer_token
                     }
                   },
                   target2.name.to_s => {
                     'api' => target2.api,
                     'team' => target2.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target2.bearer_token
                     }
                   }
                 }
               }))
    end

    it 'creates the parent directory on write when it does not exist' do
      fly_home_dir = '/some/home'

      target1 = Build::Data.random_target
      target2 = Build::Data.random_target

      rc = described_class.new(
        home: fly_home_dir,
        targets: [target1, target2]
      )
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents)
        .to(eq({
                 'targets' => {
                   target1.name.to_s => {
                     'api' => target1.api,
                     'team' => target1.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target1.bearer_token
                     }
                   },
                   target2.name.to_s => {
                     'api' => target2.api,
                     'team' => target2.team.to_s,
                     'token' => {
                       'type' => 'bearer',
                       'value' => target2.bearer_token
                     }
                   }
                 }
               }))
    end
  end
end
