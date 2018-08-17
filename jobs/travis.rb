require 'yaml'
require File.expand_path('../../lib/config', __FILE__)
require File.expand_path('../../lib/formatter', __FILE__)
require File.expand_path('../../lib/travis', __FILE__)

SCHEDULER.every '2m', :first_in => '1s' do |job|

    config = Config.new
    formatter = Formatter.new
    travis = TravisClient.new

    builds = []

    config.get_repos.each { |repo_slug|
        build = travis.get_client().repo(repo_slug)

        builds.push({
            'repo_slug': repo_slug,
            'label': formatter.label_from_slug(repo_slug),
            'green': build.green?,
        })
    }

    send_event('travis', { builds: builds })

end
