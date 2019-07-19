require 'faraday'
require 'yaml'
require 'uri'
require 'json'
require 'tzinfo'

require File.expand_path('../../lib/config', __FILE__)
require File.expand_path('../../lib/formatter', __FILE__)

SCHEDULER.every '10m', :first_in => '1s' do |job|

    raise ArgumentError, 'TRAVIS_ACCESS_TOKEN is not available in environment' unless ENV['TRAVIS_ACCESS_TOKEN'];
    travis_token = ENV['TRAVIS_ACCESS_TOKEN']

    config = Config.new
    formatter = Formatter.new

    builds = []

    conn = Faraday.new(:url => 'https://api.travis-ci.org/') do |faraday|
        faraday.headers['Travis-API-Version'] = '3'
        faraday.headers['Authorization'] = "token #{travis_token}"
        faraday.adapter  Faraday.default_adapter
    end

    config.get_repos.each do |repo_slug|
        repo_slug_for_url = URI::escape(repo_slug, '#/#')
        response = conn.get "/repo/#{repo_slug_for_url}/branches"
        branches = JSON.parse(response.body)

        # Ensure we have branch build information available
        if !branches || !branches['branches']
            next
        end

        repo_branch_blacklist = []
        if config.get_branch_blacklist(repo_slug)
            repo_branch_blacklist = config.get_branch_blacklist(repo_slug)
        end
        repo_builds = []
        repo_green = true

        # Get each branch and latest build
        # branches.each_pair do |branch_name, branch_build|
        branches['branches'].each do |branch|
            # Check the branch matches the whitelist
            if not /^(\d+\.\d+$|master)/.match(branch['name'])
                next
            end

            # Check it's not explicitly blacklisted
            if repo_branch_blacklist.include?(branch['name'])
                next
            end

            # Branch is good, store build details
            # See https://github.com/travis-ci/travis.rb/blob/master/lib/travis/client/states.rb
            branch_state = branch['last_build']['state']
            build_data = {
                :branch => branch['name'],
                :green  => !!['ready', 'passed'].include?(branch_state),
                :yellow => !!['created', 'queued', 'received', 'started'].include?(branch_state),
                :red    => !!['errored', 'cancelled', 'failed'].include?(branch_state),
            }

            repo_builds.push(build_data)

            # If a branch is failing, mark repo as failing
            if build_data['green'.to_sym] == false
                repo_green = false
            end

            # If a branch is building, mark repo as "not green" so it will show in progress builds
            if build_data['yellow'.to_sym] == true
                repo_green = false
            end
        end

        repo = {
            'repo_slug': repo_slug,
            'label': formatter.label_from_slug(repo_slug),
            'builds': repo_builds,
            'green': repo_green,
        }
        builds.push(repo)
    end

    # Group all non-green builds first, then sort alphabetically (ignoring case)
    builds.sort_by!{ |hsh| [ hsh[:green] ? 2 : 1, hsh[:label].downcase ] }

    # Get the current authenticated user's name
    user_response = conn.get '/user'
    user = JSON.parse(user_response.body)

    # Pass the current time so we can display last updated. Note this is using
    # version 1.2.5 of the TZInfo API.
    aucklandTimezone = TZInfo::Timezone.get('Pacific/Auckland')
    updatedAt = aucklandTimezone.utc_to_local(Time.now.utc).strftime('%Y-%m-%d %H:%M:%S (NZ)')

    send_event('travis', {
        'builds': builds,
        'user': user['name'],
        'updated': updatedAt,
    })

end
