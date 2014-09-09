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
		<hr />
		<hr />
		<div id="todolistapp-configuration">
			<form role="form">
				<div class="form-group">
					<label for="username">Benutzername</label>
					<input type="url" class="form-control username" placeholder="Mein Name ist??" required />
				</div>
				<hr />
				<div class="form-group">
					<label for="replicateurl">Adresse zum Replizieren</label>
					<input type="url" class="form-control replicateurl" placeholder="http://" required />
				</div>
				<div class="checkbox">
					<label>
						<input type="checkbox" class="continuousreplication" required> Durchgängige Replikation
					</label>
				</div>
				<div class="form-group replicationinterval">
					<label for="replicationinterval">Replikationsinterval</label>
					<div class="input-group">
						<input class="form-control replicationinterval" required type="number" min="0" step="3" placeholder="0" />
						<div class="input-group-addon">sek</div>
					</div>
				</div>
				<hr />
				<button type="reset" class="btn btn-default">Zurücksetzen</button>
				<button type="submit" class="btn btn-default">Speichern</button>
			</form>
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

