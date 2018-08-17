class Dashing.Travis extends Dashing.Widget

    ready: ->
        # This is fired when the widget is done being rendered
        #$(@node).find('ul').remove()

    onData: (data) ->
        # Fired whenever the widget receives data
        for key,build of data.builds
            if build.green
                data.builds[key]['class'] = 'build--success'
            else
                data.builds[key]['class'] = 'build--failed'
