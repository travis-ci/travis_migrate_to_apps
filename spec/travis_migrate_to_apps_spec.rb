describe TravisMigrateToApps::Cli do
  let(:owner_name)   { 'travis-ci' }
  let(:travis_token) { 'travis_token' }
  let(:github_token) { 'github_token' }
  let(:run) { described_class.new(owner_name, travis_token, github_token).run }

  let(:urls) do
    {
      installation:  'https://api.travis-ci.com/owner/travis-ci?include=owner.installation',
      repos:         'https://api.travis-ci.com/owner/travis-ci/repos?limit=20&offset=%i&repository.active=true&repository.managed_by_installation=false',
      install_repos: 'https://api.github.com/user/installations/%i/repositories/%i'
    }
  end

  let(:bodies) do
    {
      installation: '{ "installation": { "repository_id": 1, "github_id": 2 } }',
      repos:        '{ "repositories": [{ "name": "%s", "github_id": %i }], "@pagination": { "is_last": %s } }',
    }
  end

  def url(key, *args)
    urls[key] % args
  end

  def body(key, *args)
    bodies[key] % args
  end

  before do
    stub_request(:get, url(:installation)).to_return(status: 200, body: body(:installation))
    stub_request(:get, url(:repos, 0)).to_return(status: 200, body: body(:repos, 'travis-api', 3, false))
    stub_request(:get, url(:repos, 20)).to_return(status: 200, body: body(:repos, 'travis-web', 4, true))
    stub_request(:put, /.*/)
  end

  describe 'api requests', silence: true do
    before { run }
    it { expect(WebMock).to have_requested(:put, url(:install_repos, 2, 3)) }
    it { expect(WebMock).to have_requested(:put, url(:install_repos, 2, 4)) }
  end

  it { expect { run }.to output /Starting to migrate the account travis-ci to use the Travis CI GitHub App integration/ }
  it { expect { run }.to output /Looking up travis-ci's GitHub App installation/ }
  it { expect { run }.to output /Looking up travis-ci's active repositories/ }
  it { expect { run }.to output /Starting to migrate 2 repositories/ }
  it { expect { run }.to output /Migrating repository travis-api ... done/ }
  it { expect { run }.to output /Migrating repository travis-web ... done/ }
  it { expect { run }.to output /Done/ }

  def output(*args)
    super(*args).to_stdout
  end
end
