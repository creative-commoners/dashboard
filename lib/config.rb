# Provides access to the dashboard configuration
class Config
    attr_accessor :filename

    # Returns the configuration file name
    def get_filename
        if @filename
            return @filename
        end

        return 'config.yml'
    end

    # Gets the list of configured repositories to inspect
    def get_repos
        fullPath = File.expand_path('../../' + self.get_filename, __FILE__)
        config = YAML.load_file(fullPath)

        return config['repositories']
    end
end
