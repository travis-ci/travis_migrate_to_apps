require 'webmock'
require 'webmock/rspec'
require 'travis_migrate_to_apps'
require 'support/silence'

WebMock.disable_net_connect!

RSpec.configure do |c|
  c.include Support::Silence, silence: true
end
