describe TravisMigrateToApps do
  let(:owner_name)   { 'travis-ci' }
  let(:travis_token) { 'travis_token' }
  let(:github_token) { 'github_token' }
  let(:run) { described_class.new(owner_name, travis_token, github_token).run }

  before do
    stub_request(:get, 'https://api.travis-ci.com/owner/travis-ci?include=owner.installation').
      to_return(status: 200, body: '{ "installation": { "repository_id": 1, "github_id": 2 } }')

    stub_request(:get, 'https://api.travis-ci.com/owner/travis-ci/repos?limit=20&offset=0&repository.active=true&repository.managed_by_installation=false').
      to_return(status: 200, body: '{ "repositories": [{ "name": "travis-api", "github_id": 3 }], "@pagination": { "is_last": true } }')

    stub_request(:put, /.*/)
    run
  end

  it { expect(WebMock).to have_requested(:put, 'https://api.github.com/user/installations/2/repositories/3') }
end
