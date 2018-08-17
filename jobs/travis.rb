require File.expand_path('../../lib/config', __FILE__)
require File.expand_path('../../lib/formatter', __FILE__)
require File.expand_path('../../lib/travis', __FILE__)

SCHEDULER.every '10m', :first_in => '1s' do |job|

    config = Config.new
    formatter = Formatter.new
    travis = TravisClient.new

    builds = []

    config.get_repos.each do |repo_slug|
        build = travis.get_client().repo(repo_slug)

        repo_branch_blacklist = []
        if config.get_branch_blacklist(repo_slug)
            repo_branch_blacklist = config.get_branch_blacklist(repo_slug)
        end
        repo_builds = []
        repo_green = true

        # Ensure we have branch build information available
        if !build.branches
            next
        end

        # Get each branch and latest build
        build.branches.each_pair do |branch_name, branch_build|
            # Check the branch matches the whitelist
            if not /^(\d+\.\d+$|master)/.match(branch_name)
                next
            end

            # Check it's not explicitly blacklisted
            if repo_branch_blacklist.include?(branch_name)
                next
            end

            # Branch is good, store build details
            build_data = {
                'branch': branch_name,
                'green': branch_build.green?,
            }
            repo_builds.push(build_data)

            # If a branch is failing, mark repo as failing
            if not branch_build.green?
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

    send_event('travis', { builds: builds })

end
