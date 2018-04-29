require 'net/https'
require 'json'
require 'colors'

class TravisMigrateToApps < Struct.new(:owner_name, :travis_access_token, :github_access_token)
  include Colors

  USAGE = 'Usage: travis_migrate_to_apps [owner_name] [travis_access_token] [github_access_token]'

  MSGS = {
    start:                'Starting to migrate the account %s to use the Travis CI GitHub App integration.',
    fetch_installation:   "Looking up %s's GitHub App installation.",
    fetch_repos:          "Looking up %s's active repositories.",
    migrate_repos:        'Starting to migrate %i repositories.',
    migrating_repo:       'Migrating repository %s ... ',
    migrated_repo:        'done.',
    done:                 'Done.',
    missing_installation: 'Sorry, we could not find an active installation for %s.',
    missing_repos:        'Sorry, we could not find any repositories to migrate.',
    request_failed:       "Sorry, a %s request to %s failed, please check your auth token. (%i: %s)",
  }

  URIS = {
    travis: {
      installation: 'https://api.travis-ci.com/owner/%s?include=owner.installation',
      repositories: 'https://api.travis-ci.com/owner/%s/repos?repository.active=true&repository.managed_by_installation=false&limit=%i&offset=%i'
    },
    github: {
      installation_repos: 'https://api.github.com/user/installations/%i/repositories/%i'
    }
  }

  HEADERS = {
    travis: {
      'Travis-API-Version' => '3',
      'User-Agent'         => 'Travis GitHub App Migration Tool',
      'Authorization'      => 'token %{token}'
    },
    github: {
      'Accept'        => 'application/vnd.github.machine-man-preview+json',
      'Authorization' => 'token %{token}'
    }
  }

  PER_PAGE = 20

  attr_reader :installation

  def initialize(*)
    super
    to_h.keys.each do |key|
      missing_arg(key) unless send(key)
    end
  end

  def run
    msg :start, owner_name, color: :yellow
    validate
    migrate_repos
    msg :done, color: :green
  end

  private

    def installation
      @installation ||= fetch_installation
    end

    def repos
      @repos ||= begin
        msg :fetch_repos, owner_name
        fetch_repos
      end
    end

    def validate
      error :missing_installation, owner_name unless installation
      error :missing_repos                    unless repos.any?
    end

    def migrate_repos
      msg :migrate_repos, repos.count
      repos.each { |repo| migrate_repo(repo) }
    end

    def migrate_repo(repo)
      msg :migrating_repo, repo['name'], nl: false
      uri = uri(:github, :installation_repos, installation['github_id'], repo['github_id'])
      request(:put, uri, headers(:github))
      msg :migrated_repo, repo['name']
    end

    def fetch_installation
      msg :fetch_installation, owner_name
      uri = uri(:travis, :installation, owner_name)
      data = request(:get, uri, headers(:travis))
      data['installation']
    end

    def fetch_repos(repos = [], page = 1)
      offset = (page - 1) * PER_PAGE
      uri    = uri(:travis, :repositories, owner_name, PER_PAGE, offset)
      data   = request(:get, uri, headers(:travis))
      repos += data['repositories'].map { |repo| only(repo, 'name', 'github_id') }
      repos  = fetch_repos(repos, page + 1) unless data['@pagination']['is_last']
      repos
    end

    def uri(target, resource, *args)
      URI(URIS[target][resource] % args)
    end

    def headers(target)
      args = { token: send(:"#{target}_access_token") }
      HEADERS[target].map { |key, value| [key, value % args] }.to_h
    end

    def request(method, uri, headers)
      req = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
      headers.each { |key, value| req[key] = value }
      http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true)
      res = http.request(req)
      error :request_failed, method, uri, res.code, res.body unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body) if method == :get
    end

    def error(key, *args)
      abort colored(:red, MSGS[key] % args)
    end

    def msg(key, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      msg = MSGS[key] % args
      msg = colored(opts[:color], msg) if opts[:color]
      method = opts[:nl].is_a?(FalseClass) ? :print : :puts
      send(method, msg)
    end

    def missing_arg(key)
      puts colored(:red, "No #{key} given")
      puts USAGE
      abort
    end

    def only(hash, *keys)
      hash.select { |key, _| keys.include?(key) }
    end
end
