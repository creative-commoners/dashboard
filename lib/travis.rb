require 'travis/client'

# Wrapper for accessing Travis with authorization provided from the environment variable
class TravisClient
    attr_accessor :client

    def initialize
        raise ArgumentError, 'TRAVIS_ACCESS_TOKEN is not available in environment' unless ENV['TRAVIS_ACCESS_TOKEN']

        @client = Travis::Client.new(access_token: ENV['TRAVIS_ACCESS_TOKEN'])
    end

    def get_client
        return @client
    end
end
