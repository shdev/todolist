### https://gist.github.com/alecperkins/3363111 ###

# Backbone.sync = BackbonePouch.sync()
# Backbone.sync =  BackbonePouch.sync db: PouchDB('svh_todo')
#
# @pouchdb = new PouchDB('svh_todo')
# @pouchdb .changes().on 'change', ->
# 	console.log 'Ch-Ch-Changes'
#
# @pouchdb.replicate.to('http://127.0.0.1:5984/svh_todo', {live : true});
# @pouchdb.replicate.from('http://127.0.0.1:5984/svh_todo', {live : true});


class TodoListApplication extends Marionette.Application

App =  new TodoListApplication();


# App.on 'all', (a,b,c,d,e)->
# 		console.log 'App events' + a

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

