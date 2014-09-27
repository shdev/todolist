App.module 'TodoListApp', (TodoListApp, App, Backbone, Marionette, $, _) ->

	###
	TODO requestHandling for the classes
	###

	class TodoListAppView extends Marionette.LayoutView
		className : "container-fluid"
		template : _.template """
		<div class="row">
			<div id="topbar"></div>
			<div id="todolistapp-lists" class="col-md-4">
				<div id="todolistapp-list-input"></div>
				<hr />
				<div id="todolistapp-lists-view"></div>
			</div>
			<hr class="hidden-md hidden-lg" />
			<hr class="hidden-md hidden-lg" />
			<div id="todolistapp-entries" class="col-md-4">
				<div id="todolistapp-entry-input"></div>
				<hr />
				<div id="todolistapp-entries-view"></div>
			</div>
			<hr  class="hidden-md hidden-lg" />
			<hr  class="hidden-md hidden-lg" />
			<div id="todolistapp-configuration" class="col-md-4"></div>
		</div>
		"""
		regions : 
			topBar : "#topbar"
			listsArea : "#todolistapp-lists"
			listInput : "#todolistapp-list-input"
			listsView : "#todolistapp-lists-view"
			entriesArea : "#todolistapp-entries"
			entryInput : "#todolistapp-entry-input"
			entriesView : "#todolistapp-entries-view"
			configurationView : "#todolistapp-configuration"

	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoListAppView

	pouchDB = undefined

	App.reqres.setHandler "TodoListApp:PouchDB", () ->
		pouchDB = new PouchDB('svh_todo', adapter : 'websql') if not pouch?
		pouchDB

	App.vent.on 'todolist:configurationloaded', (config) ->
		console.debug 'todolist:configurationloaded'
		App.request("TodoListApp:PouchDB");
		App.vent.trigger 'todolistapp:startReplication'
		App.vent.trigger 'todolistapp:initViews'
		
		currentConfiguration = App.request("TodoListApp:Configuration")
		
		currentConfiguration.on 'change', () ->
			App.vent.trigger 'todolistapp:startReplication'
		
		
	App.vent.on 'todolistapp:initViews', () ->
		console.debug 'todolistapp:initViews'
		TodoListApp.mainView = new TodoListAppView()
		console.debug TodoListApp.mainView
		window.TodoListApp = TodoListApp
		App.mainRegion.show(TodoListApp.mainView)
	
	pouchdbRepTo = undefined
	pouchdbRepFrom = undefined
	
	window.pouchdbRepTo = pouchdbRepTo
	
	timeOutRepTo = undefined
	timeOutRepFrom = undefined
	
	doReplicationTo = () ->
		console.debug 'doReplicationTo'
		currentPouchDB = App.request("TodoListApp:PouchDB");
		currentConfiguration = App.request("TodoListApp:Configuration")
		if timeOutRepTo?
			console.debug 'Clear To Timer'
			clearTimeout(timeOutRepTo)
			timeOutRepTo = undefined
		if pouchdbRepTo?
			pouchdbRepTo.cancel()
			App.vent.trigger 'replication:pouchdb:to:cancel'
		
		pouchdbRepTo = undefined
			
		if not pouchdbRepTo? and currentConfiguration.get('replicateurl')?
			pouchdbRepTo = currentPouchDB.replicate.to( currentConfiguration.get('replicateurl'), {live : currentConfiguration.get('continuousreplication')}) 
			window.pouchdbRepTo = pouchdbRepTo
			pouchdbRepTo.on 'uptodate', () ->
				console.debug 'pouchdbRepTo:uptodate'
				App.vent.trigger 'replication:pouchdb:to:uptodate'
			pouchdbRepTo.on 'error', () ->
				console.debug 'pouchdbRepTo:error'
				pouchdbRepTo.cancel()
				pouchdbRepTo = undefined
				App.vent.trigger 'replication:pouchdb:to:error'
				if currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepTo = setTimeout(doReplicationTo, currentConfiguration.get('replicationinterval') * 1000)
			pouchdbRepTo.on 'change', ()->
				console.debug 'pouchdbRepTo:change'
				App.vent.trigger 'replication:pouchdb:to:change'
			pouchdbRepTo.on 'complete', () ->
				console.debug 'pouchdbRepTo:complete'
				App.vent.trigger 'replication:pouchdb:to:complete'
				if not currentConfiguration.get('continuousreplication') and currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepTo = setTimeout(doReplicationTo, currentConfiguration.get('replicationinterval') * 1000)

	doReplicationFrom = () ->
		console.debug 'doReplicationFrom'
		currentPouchDB = App.request("TodoListApp:PouchDB");
		currentConfiguration = App.request("TodoListApp:Configuration")
		
		if timeOutRepFrom?
			clearTimeout(timeOutRepFrom)
			timeOutRepFrom = undefined
		
		if pouchdbRepFrom?
			pouchdbRepFrom.cancel()
			App.vent.trigger 'replication:pouchdb:from:cancel'
		
		pouchdbRepFrom = undefined
		
		if not pouchdbRepFrom? and currentConfiguration.get('replicateurl')?
			pouchdbRepFrom = currentPouchDB.replicate.from(currentConfiguration.get('replicateurl'), {live : currentConfiguration.get('continuousreplication')}) 
		
			pouchdbRepFrom.on 'uptodate', ()->
				console.debug 'pouchdbRepFrom:update'
				# App.vent.trigger 'replication:pouchdb:from:uptodate'
				App.vent.trigger 'replication:pouchdb:from:uptodate'

			pouchdbRepFrom.on 'error', ()->
				console.debug 'pouchdbRepFrom:error'
				pouchdbRepFrom.cancel()
				pouchdbRepFrom = undefined
				App.vent.trigger 'replication:pouchdb:from:error'
				if currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepFrom = setTimeout(doReplicationFrom, currentConfiguration.get('replicationinterval') * 1000)
			
			pouchdbRepFrom.on 'change', ()->
				console.debug 'pouchdbRepFrom:change'
				App.vent.trigger 'replication:pouchdb:from:change'
			
			pouchdbRepFrom.on 'complete', () ->
				console.debug 'pouchdbRepFrom:complete'
				App.vent.trigger 'replication:pouchdb:from:complete'
				if not currentConfiguration.get('continuousreplication') and currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepFrom = setTimeout(doReplicationFrom, currentConfiguration.get('replicationinterval') * 1000)
		
		
	
	App.vent.on 'todolistapp:startReplication', () -> 
		doReplicationTo()
		doReplicationFrom()

	TodoListApp.run = -> 
			# Backbone.sync = BackbonePouch.sync()
			# Backbone.sync =  BackbonePouch.sync db: PouchDB('svh_todo')
			###
			TODO a better replication handling
			###
			# @pouchdb = new PouchDB('svh_todo', adapter : 'websql')

			# @pouchdbRepTo = @pouchdb.replicate.to('http://192.168.50.30:5984/svh_todo', {live : true})
			#
			# @pouchdbRepTo.on 'uptodate', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.to.on uptodate'
			# 				App.vent.trigger 'replication:svh_todo:uptodate'
			#
			# pouchdbRepTo = @pouchdbRepTo
			# @pouchdbRepTo.on 'error', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.to.on error'
			# 				console.log a
			# 				pouchdbRepTo.cancel();
			#
			# @pouchdbRepTo.on 'complete', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.to.on complete'
			# 				console.log a
			# 				App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?
			#
			# @pouchdbRepFrom = @pouchdb.replicate.from('http://192.168.50.30:5984/svh_todo', {live : true})
			#
			# @pouchdbRepFrom.on 'uptodate', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.from.on uptodate'
			# 				App.vent.trigger 'replication:svh_todo:uptodate'
			#
			#
			# pouchdbRepFrom = @pouchdbRepFrom
			# @pouchdbRepFrom.on 'error', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.from.on error'
			# 				console.log a
			# 				pouchdbRepFrom.cancel()
			#
			# @pouchdbRepFrom.on 'complete', (a,b,c,d)->
			# 				console.log '@pouchdb.replicate.from.on complete'
			# 				console.log a
			# 				App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?


			
			window.TodoListApp
			App.vent.trigger('app:initialized', App)
	
	App.vent.on 'replication:svh_todo:uptodate', () -> 
		App.TodoListApp.listCollection.fetch() if App.TodoListApp.listCollection?
		App.TodoListApp.entryCollection.fetch() if App.TodoListApp.entryCollection?
			
	
	# TodoListApp.on 'all', (a)->
	# console.log 'TodoListApp events' + a

	App.addInitializer () ->
		console.debug 'TodoListApp App.addInitializer'
		TodoListApp.run()

