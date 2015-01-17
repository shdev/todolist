This is the starting point for the web app.

We extend the Marionette.Application to a new class just for the name.

    class TodoListApplication extends Marionette.Application
    
and instantiate a app
    
    App =  new TodoListApplication();

We define on which elemente the app will live

    App.addRegions(
      mainRegion : 'body'
    )

We use later on behaviors from Marionette.js, here we set the place for them
        
    window.Behaviors = {} if not window.Behaviors?
    Marionette.Behaviors.behaviorsLookup = ->
      return window.Behaviors

Moment.js needs to know the formating

    moment.lang('de')


the init function, everything for the startup is here.

    init = ( ) ->
                    
Tada, start the app

      App.start()

Start the init.

    $(init)

