class Formatter
    # Define organisations that should be stripped from repo slugs
    # @todo move this to Config
    def get_organisations()
        return [
            'bringyourownideas',
            'dnadesign',
            'silverstripe',
            'symbiote',
            'tractorcow'
        ]
    end

    # Convert a repo slug into a label for display
    def label_from_slug(slug)
        self.get_organisations().each do |organisation|
            slug = slug.gsub(/#{organisation}\//, '')
        end

        return slug
    end
end
