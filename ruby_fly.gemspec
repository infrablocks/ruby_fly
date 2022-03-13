# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_fly/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby_fly'
  spec.version = RubyFly::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.summary = 'A simple Ruby wrapper for invoking fly commands.'
  spec.description = 'Wraps the concourse fly CLI so that fly can be invoked from a Ruby script or Rakefile.'
  spec.homepage = 'https://github.com/infrablocks/ruby_fly'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(bin|lib|CODE_OF_CONDUCT\.md|confidante\.gemspec|Gemfile|LICENSE\.txt|Rakefile|README\.md)})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'lino', '~> 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake_circle_ci'
  spec.add_development_dependency 'rake_github'
  spec.add_development_dependency 'rake_ssh'
  spec.add_development_dependency 'rake_gpg'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'gem-release'
end
