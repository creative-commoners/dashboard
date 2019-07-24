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

    # Given a coverage percentage, return an appropriate bar colour for it
    # Output is to be used in `rgba({return}, 0.5)` for example
    def coverage_to_colour(coverage)
        color = '';
        coverage = coverage.to_f

        if coverage < 40
            color = '255, 0, 0' # red
        elsif coverage < 70
            color = '255, 79, 0' # orange
        else
            color = '0, 113, 0' # green
        end

        return color
    end
end
