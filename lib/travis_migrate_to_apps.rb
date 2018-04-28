require 'net/https'
require 'json'

class TravisMigrateToApps < Struct.new(:owner_name, :travis_access_token, :github_access_token)
  USAGE = 'Usage: travis_migrate_to_apps [owner_name] [travis_access_token] [github_access_token]'

  def initialize(*)
    super
    to_h.keys.each do |key|
      abort "#{USAGE}\nNo #{key} given" unless send(key)
    end
  end

  def run
    puts "Starting Migration for : #{owner_name}"

    installation = find_installation

    if !installation
      puts "Sorry but we couldn't find an active installation for #{owner_name}"
      exit
    end

    repos = find_repos_to_migrate

    if repos.empty?
      puts "Sorry but we couldn't find any repositories to migrate"
      exit
    end

    puts
    puts "Found #{repos.count} repositories to migrate"
    puts "Starting the migration..."

    repos.each do |repo|
      add_repo_to_installation(repo['github_id'], installation['github_id'])
      puts "migrated - #{repo['name']}"
    end

    puts
    puts "Huzzah! All done!"
  end

  private

    def find_repos_to_migrate(repos=[], page=1)
      limit = 20
      offset = (page - 1) * limit

      uri = URI("https://api.travis-ci.com/owner/#{owner_name}/repos?repository.active=true&repository.managed_by_installation=false&limit=#{limit}&offset=#{offset}")

      req = Net::HTTP::Get.new(uri)
      req['Travis-API-Version'] = "3"
      req['User-Agent'] = "Travis Apps Migration Assistant"
      req['Authorization'] = "token #{travis_access_token}"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end

      if !res.is_a?(Net::HTTPSuccess)
        rputs
        puts "Sorry but we had problem talking to Travis CI, please check your auth token"
        puts res.body.inspect
      else
        decoded = JSON.parse(res.body)
        repos += decoded['repositories'].map { |repo| only(repo, "name", "github_id") }
        if !decoded["@pagination"]["is_last"]
          find_repos_to_migrate(repos, page + 1)
        else
          repos
        end
      end
    end

    def find_installation
      uri = URI("https://api.travis-ci.com/owner/#{owner_name}?include=owner.installation")

      req = Net::HTTP::Get.new(uri)
      req['Travis-API-Version'] = "3"
      req['User-Agent'] = "Travis Apps Migration Assistant"
      req['Authorization'] = "token #{travis_access_token}"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end

      if !res.is_a?(Net::HTTPSuccess)
        puts
        puts "Sorry but we had problem talking to Travis CI, please check your auth token"
        puts res.body.inspect
        raise
      else
        decoded = JSON.parse(res.body)
        decoded['installation']
      end
    end

    def add_repo_to_installation(repository_github_id, installation_id)
      uri = URI("https://api.github.com/user/installations/#{installation_id}/repositories/#{repository_github_id}")

      req = Net::HTTP::Put.new(uri)
      req['Authorization'] = "token #{github_access_token}"
      req['Accept'] = "application/vnd.github.machine-man-preview+json"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end

      if !res.is_a?(Net::HTTPSuccess)
        puts
        puts "Sorry but we had problem talking to GitHub, please check your auth token"
        puts res.body.inspect
      else
        true
      end
    end

    def only(hash, *keys)
      hash.select { |key, _| keys.include?(key) }
    end
end
