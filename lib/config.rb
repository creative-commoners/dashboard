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

    # Whether to strip repository names for labels
    def strip_repo_slugs_for_labels
        return @data['strip_repo_slugs_for_labels']
    end
end
