### https://gist.github.com/alecperkins/3363111 ###

class TodoListApplication extends Marionette.Application

App =  new TodoListApplication();

# App.on 'all', (a,b,c,d,e)->
# 		console.log 'App events' + a
#
# App.vent.on 'all', (a,b,c,d,e)->
# 		console.log 'App vents ' + a

App.addRegions(
	mainRegion : 'body'
)

window.Behaviors = {} if not window.Behaviors?

Marionette.Behaviors.behaviorsLookup = ->
	return window.Behaviors


init = ( ) -> 
	moment.lang('de')
	App.start()
	
$(init)

