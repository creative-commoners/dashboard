class Dashing.Travis extends Dashing.Widget

    ready: ->
        # This is fired when the widget is done being rendered
        #$(@node).find('ul').remove()

    onData: (data) ->
        # Fired whenever the widget receives data

        # Add class for whether repos overall builds are passing
        for x,repo of data.builds
            if repo.green
                data.builds[x]['class'] = 'repo build--success'
            else
                data.builds[x]['class'] = 'repo build--failed'

            # Add class for whether individual repo builds are passing, failed or in progress
            for y,build of repo.builds
                if build.green
                    data.builds[x]['builds'][y]['class'] = 'repo__build build--success';
                else if build.yellow
                    data.builds[x]['builds'][y]['class'] = 'repo__build build--running';
                else
                    data.builds[x]['builds'][y]['class'] = 'repo__build build--failed';
