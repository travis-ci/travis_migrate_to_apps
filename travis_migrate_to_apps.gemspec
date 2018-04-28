# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis_migrate_to_apps/version'

Gem::Specification.new do |s|
  s.name          = 'travis_migrate_to_apps'
  s.version       = TravisMigrateToApps::VERSION
  s.authors       = ['Travis CI']
  s.email         = ['support@travis-ci.com']
  s.homepage      = 'https://github.com/travis-ci/travis_migrate_to_apps'
  s.licenses      = ['MIT']
  s.summary       = 'Migrate your GitHub organizations to use the Travis CI GitHub App integration'
  s.description   = 'Migrate your GitHub organizations to use the Travis CI GitHub App integration.'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
end
