require 'faraday'
require 'yaml'
require 'uri'
require 'json'
require 'tzinfo'

require File.expand_path('../../lib/config', __FILE__)
require File.expand_path('../../lib/formatter', __FILE__)

SCHEDULER.every '24h', :first_in => '1s' do |job|

    # Ensure the API token is available in the environment
    raise ArgumentError, 'CODECOV_ACCESS_TOKEN is not available in environment' unless ENV['CODECOV_ACCESS_TOKEN'];
    access_token = ENV['CODECOV_ACCESS_TOKEN']

    config = Config.new
    formatter = Formatter.new

    # x basis labels
    labels = []

    # Coverage number store
    coverageResults = []

    # Coverage colours per result
    backgroundColors = []
    borderColors = []

    repos = config.get_repos

    # Group repos by organisation. Codecov will list all repos under an organisation,
    # which will save API requests
    config.get_organisations.each do |organisation|
        # Get the API response from Codecov
        begin
            # Set up the HTTP connection
            conn = Faraday::Connection.new;
            conn.options.timeout = 30 # seconds
            conn.options.open_timeout = 30 # seconds
            response = conn.get("https://codecov.io/api/gh/#{organisation}", [], {
                'Authorization': "token #{access_token}"
            })
            apiResult = JSON.parse(response.body)
        rescue StandardError => e
            puts "Error fetching #{organisation} coverage information: #{e.message}"
        end

        # Ensure we have build information available
        if !apiResult || !apiResult['repos'] || apiResult['repos'].length === 0
            next
        end

        # Now find each repo that is in the organisation's codecov API result
        apiResult['repos'].each do |repo_data|
            repo_slug = "#{organisation}/#{repo_data['name']}"

            # Check if it is one of the modules we watch
            unless repos.include?(repo_slug)
                next
            end

            # Track the current repo
            coverageResult = repo_data['coverage']

            labels.push(formatter.label_from_slug(repo_slug))

            coverageResults.push(coverageResult)
            coverageColor = formatter.coverage_to_colour(coverageResult)
            backgroundColors.push('rgba(' + coverageColor + ', 0.5)')
            borderColors.push('rgba(' + coverageColor + ', 0.9)')
        end
    end

    data = [
        {
            label: 'Code coverage percentage',
            data: coverageResults,
            backgroundColor: backgroundColors,
            borderColor: borderColors,
            borderWidth: 1,
        },
    ]

    options = {}

    # Pass the current time so we can display last updated. Note this is using
    # version 1.2.5 of the TZInfo API.
    aucklandTimezone = TZInfo::Timezone.get('Pacific/Auckland')
    updatedAt = aucklandTimezone.utc_to_local(Time.now.utc).strftime('%Y-%m-%d %H:%M:%S (NZ)')

    send_event('coverage', {
        labels: labels,
        datasets: data,
        options: options,
        updated: updatedAt,
    })

end
