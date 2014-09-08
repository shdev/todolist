App.module 'TodoListApp', (TodoListApp, App, Backbone, Marionette, $, _) ->

	class TodoListAppView extends Marionette.LayoutView
		className : "container"
		template : _.template """
		<div id="todolistapp-lists">
			<div id="todolistapp-list-input"></div>
			<hr />
			<div id="todolistapp-lists-view"></div>
		</div>
		<hr />
		<hr />
		<div id="todolistapp-entries">
			<div id="todolistapp-entry-input"></div>
			<hr />
			<div id="todolistapp-entries-view"></div>
		</div>
		"""
		regions : 
			listsArea : "#todolistapp-lists"
			listInput : "#todolistapp-list-input"
			listsView : "#todolistapp-lists-view"
			entriesArea : "#todolistapp-entries"
			entryInput : "#todolistapp-entry-input"
			entriesView : "#todolistapp-entries-view"

	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoListAppView

	TodoListApp.run = -> 
			console.debug 'TodoListApp.run'
			console.debug @
			
			# Backbone.sync = BackbonePouch.sync()
			# Backbone.sync =  BackbonePouch.sync db: PouchDB('svh_todo')

			###
			TODO a better replication handling
			###
			
			@pouchdb = new PouchDB('svh_todo', adapter : 'websql')

			@pouchdbRepTo = @pouchdb.replicate.to('http://192.168.50.30:5984/svh_todo', {live : true})
			
			@pouchdbRepTo.on 'uptodate', (a,b,c,d)->
							console.log '@pouchdb.replicate.to.on uptodate'
							App.vent.trigger 'replication:svh_todo:uptodate'
							
			pouchdbRepTo = @pouchdbRepTo
			@pouchdbRepTo.on 'error', (a,b,c,d)->
							console.log '@pouchdb.replicate.to.on error'
							console.log a
							pouchdbRepTo.cancel();
							
			@pouchdbRepTo.on 'complete', (a,b,c,d)->
							console.log '@pouchdb.replicate.to.on complete'
							console.log a
							App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?
							
			@pouchdbRepFrom = @pouchdb.replicate.from('http://192.168.50.30:5984/svh_todo', {live : true})
			
			@pouchdbRepFrom.on 'uptodate', (a,b,c,d)->
							console.log '@pouchdb.replicate.from.on uptodate'
							App.vent.trigger 'replication:svh_todo:uptodate'


			pouchdbRepFrom = @pouchdbRepFrom
			@pouchdbRepFrom.on 'error', (a,b,c,d)->
							console.log '@pouchdb.replicate.from.on error'
							console.log a
							pouchdbRepFrom.cancel()
							
			@pouchdbRepFrom.on 'complete', (a,b,c,d)->
							console.log '@pouchdb.replicate.from.on complete'
							console.log a
							App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?

			@mainView = new TodoListAppView()

			console.debug @mainView

			window.TodoListApp = @
			
			App.mainRegion.show(@mainView)
			
			console.debug @mainView.entryInput
			console.debug App.TodoListApp.mainView.entryInput
			
			window.TodoListApp
			
			App.vent.trigger('app:initialized', App)
	
	App.vent.on 'replication:svh_todo:uptodate', () -> 
		App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?
		App.TodoListApp.entryCollection.fetch() if App.TodoListApp.entryCollection?
			
	
	TodoListApp.on 'all', (a)->
		console.log 'TodoListApp events' + a 

	App.addInitializer () ->
		console.debug @
		TodoListApp.run()

