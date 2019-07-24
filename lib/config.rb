# Provides access to the dashboard configuration
class Config
    attr_accessor :data

    # Returns the configuration file name
    def initialize
        fullPath = File.expand_path('../../config.yml', __FILE__)
        @data = YAML.load_file(fullPath)
    end

    # Gets the list of configured repositories to inspect
    def get_repos
        return @data['repositories']
    end

    # Gets a list of all organisations in the list of repositories
    def get_organisations
        organisations = []
        @data['repositories'].each do |repo_slug|
            organisation = repo_slug.split('/')[0]
             unless organisations.include?(organisation)
                 organisations.push(organisation)
             end
        end
        return organisations
    end

    # Whether to strip repository names for labels
    def strip_repo_slugs_for_labels
        return @data['strip_repo_slugs_for_labels']
    end

    # Get specifically blacklisted branches
    def get_branch_blacklist(repo_slug)
        if repo_slug
            return @data['travis_branch_blacklist'][repo_slug]
        end

        return @data['travis_branch_blacklist']
    end
end
