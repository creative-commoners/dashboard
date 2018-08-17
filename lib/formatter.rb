require File.expand_path('../../lib/config', __FILE__)

class Formatter
    # Convert a repo slug into a label for display
    def label_from_slug(slug)
        config = Config.new
        stripSlugs = config.strip_repo_slugs_for_labels()

        if !stripSlugs
            return slug
        end

        # Strip "silverstripe/" organisation, and optionally "silverstripe-"
        # from repo slug
        return slug.gsub(/^[^\/]*\/(silverstripe-)?/, '')
    end
end
