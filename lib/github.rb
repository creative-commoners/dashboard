require 'octokit'

# Wrapper for accessing Octokit with authorization provided from the environment variable
class GitHub
    attr_accessor :client

    def initialize
        raise ArgumentError, 'GITHUB_ACCESS_TOKEN is not available in environment' unless ENV['GITHUB_ACCESS_TOKEN']

        @client = Octokit::Client.new(:access_token => ENV['GITHUB_ACCESS_TOKEN'])
    end
end
