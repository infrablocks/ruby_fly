require 'spec_helper'
require 'fakefs/spec_helpers'
require 'yaml'
require 'fileutils'

RSpec.describe RubyFly::RC do
  include FakeFS::SpecHelpers

  context 'on load' do
    it 'reads the contents of the RC file when it exists' do
      fly_home_dir = '/some/home'

      target_name = Build::Data.random_target_name
      target_data = Build::Data.random_target_data
      targets_data = {target_name => target_data}
      contents = {targets: targets_data}

      FileUtils.mkdir_p(fly_home_dir)
      File.open("#{fly_home_dir}/.flyrc", 'w') do |file|
        file.write(contents.to_yaml)
      end

      rc = RubyFly::RC.load(home: fly_home_dir)

      expect(rc.targets).to(eq([
          RubyFly::RC::Target.new(
              target_data.merge(name: target_name))
      ]))
    end

    it 'creates a new RC when RC file does not exist' do
      fly_home_dir = '/some/home'

      FileUtils.mkdir_p(fly_home_dir)

      rc = RubyFly::RC.load(home: fly_home_dir)

      expect(rc.targets).to(be_empty)
    end
  end

  context 'on manipulation' do
    context '#find_target' do
      it 'finds the named target in the RC when it exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        target = rc.find_target(target_1_name)

        expect(target).to(eq(target_1))
      end

      it 'return nil when the named target does not exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name
        target_3_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        target = rc.find_target(target_3_name)

        expect(target).to(be_nil)
      end
    end

    context '#add_target' do
      it 'adds the target to the RC when it does not already exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1])
        rc.add_target(target_2)

        expect(rc.find_target(target_2_name)).to(eq(target_2))
      end

      it 'throws an exception when the target already exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        expect {
          rc.add_target(target_2)
        }.to(raise_error(RubyFly::RC::TargetAlreadyPresentError,
            "Target with name: #{target_2_name} already present in RC."))
      end
    end

    context '#update_target' do
      it 'uses the provided block to update the target when it exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        access_token = Build::Data.random_access_token

        rc = RubyFly::RC.new(targets: [target_1, target_2])
        rc.update_target(target_2_name) do |target|
          target.api = "https://concourse.example.com"
          target.team = :other_team
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target_2_name)

        expect(updated_target).to(eq(
            RubyFly::RC::Target.new(
                name: target_2_name,
                api: "https://concourse.example.com",
                team: :other_team,
                token: {
                    type: 'bearer',
                    value: access_token
                })
        ))
      end

      it 'throws an exception when the target does not exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name
        target_3_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        expect {
          rc.update_target(target_3_name) do |target|
            target.token = {
                type: 'bearer',
                value: Build::Data.random_access_token
            }
          end
        }.to(raise_error(RubyFly::RC::TargetNotPresentError,
            "Target with name: #{target_3_name} not present in RC."))
      end
    end

    context '#add_or_update_target' do
      it 'uses the provided block to add the target when it does not exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        access_token = Build::Data.random_access_token

        rc = RubyFly::RC.new(targets: [target_1])
        rc.add_or_update_target(target_2_name) do |target|
          target.api = "https://concourse.example.com"
          target.team = :other_team
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target_2_name)

        expect(updated_target).to(eq(
            RubyFly::RC::Target.new(
                name: target_2_name,
                api: "https://concourse.example.com",
                team: :other_team,
                token: {
                    type: 'bearer',
                    value: access_token
                })
        ))
      end

      it 'uses the provided block to update the target when it exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        access_token = Build::Data.random_access_token

        rc = RubyFly::RC.new(targets: [target_1, target_2])
        rc.add_or_update_target(target_2_name) do |target|
          target.api = "https://concourse.example.com"
          target.bearer_token = access_token
        end

        updated_target = rc.find_target(target_2_name)

        expect(updated_target).to(eq(
            RubyFly::RC::Target.new(
                name: target_2_name,
                api: "https://concourse.example.com",
                team: target_2.team,
                token: {
                    type: 'bearer',
                    value: access_token
                })
        ))
      end
    end

    context '#rename_target' do
      it 'renames the specified target when it exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        target_2_new_name = Build::Data.random_target_name

        rc = RubyFly::RC.new(targets: [target_1, target_2])
        rc.rename_target(target_2_name, target_2_new_name)

        expect(rc.find_target(target_2_name)).to(be_nil)
        expect(rc.find_target(target_2_new_name)).to(eq(
            RubyFly::RC::Target.clone(target_2, name: target_2_new_name)))
      end

      it 'throws an exception when the target does not exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name
        target_3_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        expect {
          rc.rename_target(target_3_name, Build::Data.random_target_name)
        }.to(raise_error(RubyFly::RC::TargetNotPresentError,
            "Target with name: #{target_3_name} not present in RC."))
      end
    end

    context '#remove_target' do
      it 'removes the target from the RC when it exists' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])
        rc.remove_target(target_2_name)

        expect(rc.find_target(target_2_name)).to(be_nil)
      end

      it 'throws an exception when the target does not exist' do
        target_1_name = Build::Data.random_target_name
        target_2_name = Build::Data.random_target_name
        target_3_name = Build::Data.random_target_name

        target_1 = Build::Data.random_target(name: target_1_name)
        target_2 = Build::Data.random_target(name: target_2_name)

        rc = RubyFly::RC.new(targets: [target_1, target_2])

        expect {
          rc.remove_target(target_3_name)
        }.to(raise_error(RubyFly::RC::TargetNotPresentError,
            "Target with name: #{target_3_name} not present in RC."))
      end
    end
  end

  context 'on write' do
    it 'writes itself to the specified path when the file does not exist' do
      fly_home_dir = '/some/home'

      FileUtils.mkdir_p(fly_home_dir)

      target_1 = Build::Data.random_target
      target_2 = Build::Data.random_target

      rc = RubyFly::RC.new(
          home: fly_home_dir,
          targets: [target_1, target_2])
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents).to(eq({
          "targets" => {
              target_1.name.to_s => {
                  "api" => target_1.api,
                  "team" => target_1.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_1.bearer_token
                  }
              },
              target_2.name.to_s => {
                  "api" => target_2.api,
                  "team" => target_2.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_2.bearer_token
                  }
              }
          }
      }))
    end

    it 'overwrites the specified path when the file exists' do
      fly_home_dir = '/some/home'

      target_1_name = Build::Data.random_target_name
      target_1_data = Build::Data.random_target_data
      target_2_name = Build::Data.random_target_name
      target_2_data = Build::Data.random_target_data

      target_1 = RubyFly::RC::Target.new(
          target_1_data.merge(name: target_1_name))
      target_2 = RubyFly::RC::Target.new(
          target_2_data.merge(name: target_2_name))

      targets_data = {target_1_name => target_1_data}

      contents = {targets: targets_data}

      FileUtils.mkdir_p(fly_home_dir)
      File.open("#{fly_home_dir}/.flyrc", 'w') do |file|
        file.write(contents.to_yaml)
      end

      rc = RubyFly::RC.load(home: fly_home_dir)
      rc.add_target(target_2)
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents).to(eq({
          "targets" => {
              target_1.name.to_s => {
                  "api" => target_1.api,
                  "team" => target_1.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_1.bearer_token
                  }
              },
              target_2.name.to_s => {
                  "api" => target_2.api,
                  "team" => target_2.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_2.bearer_token
                  }
              }
          }
      }))
    end

    it 'creates the parent directory on write when it does not exist' do
      fly_home_dir = '/some/home'

      target_1 = Build::Data.random_target
      target_2 = Build::Data.random_target

      rc = RubyFly::RC.new(
          home: fly_home_dir,
          targets: [target_1, target_2])
      rc.write!

      rc_file_contents = YAML.load_file("#{fly_home_dir}/.flyrc")

      expect(rc_file_contents).to(eq({
          "targets" => {
              target_1.name.to_s => {
                  "api" => target_1.api,
                  "team" => target_1.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_1.bearer_token
                  }
              },
              target_2.name.to_s => {
                  "api" => target_2.api,
                  "team" => target_2.team.to_s,
                  "token" => {
                      "type" => "bearer",
                      "value" => target_2.bearer_token
                  }
              }
          }
      }))
    end
  end
end
