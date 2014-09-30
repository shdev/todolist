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
			<div id="todolistapp-entries" class="col-md-8">
				<div id="todolistapp-entry-input"></div>
				<hr />
				<div id="todolistapp-entries-view"></div>
			</div>
			<hr  class="hidden-md hidden-lg" />
			<div id="todolistapp-configuration" class="col-md-4 hidden"></div>
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
			
		initialize : () ->
			@listenTo App.vent, 'todolist:configuration:hideview' , () ->
				@$("#todolistapp-configuration").toggleClass 'hidden'
				@$("#todolistapp-entries").toggleClass 'col-md-4 col-md-8'

	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoListAppView

	pouchDB = undefined

	App.reqres.setHandler "todolistapp:PouchDB", () ->
		pouchDB = new PouchDB('svh_todo') if not pouch?
		pouchDB

	App.vent.on 'todolist:configurationloaded', (config) ->
		App.request("todolistapp:PouchDB");
		
		App.vent.trigger 'todolistapp:startReplication'
		App.vent.trigger 'todolistapp:initViews'
		
		currentConfiguration = App.request("todolistapp:Configuration")
		
		currentConfiguration.on 'change:continuousreplication', () ->
			App.vent.trigger 'todolistapp:startReplication'
		currentConfiguration.on 'change:replicateurl', () ->
			App.vent.trigger 'todolistapp:startReplication'
		currentConfiguration.on 'change:replicationinterval', () ->
			App.vent.trigger 'todolistapp:startReplication'
		
		
	App.vent.on 'todolistapp:initViews', () ->
		TodoListApp.mainView = new TodoListAppView()
		window.TodoListApp = TodoListApp
		App.mainRegion.show(TodoListApp.mainView)
	
	pouchdbRepTo = undefined
	pouchdbRepFrom = undefined
	
	window.pouchdbRepTo = pouchdbRepTo
	
	timeOutRepTo = undefined
	timeOutRepFrom = undefined
	
	doReplicationTo = () ->
		currentPouchDB = App.request("todolistapp:PouchDB");
		currentConfiguration = App.request("todolistapp:Configuration")
		if timeOutRepTo?
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
				App.vent.trigger 'replication:pouchdb:to:uptodate'
			pouchdbRepTo.on 'error', () ->
				pouchdbRepTo.cancel()
				pouchdbRepTo = undefined
				App.vent.trigger 'replication:pouchdb:to:error'
				if currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepTo = setTimeout(doReplicationTo, currentConfiguration.get('replicationinterval') * 1000)
			pouchdbRepTo.on 'change', ()->
				App.vent.trigger 'replication:pouchdb:to:change'
			pouchdbRepTo.on 'complete', () ->
				App.vent.trigger 'replication:pouchdb:to:complete'
				if not currentConfiguration.get('continuousreplication') and currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepTo = setTimeout(doReplicationTo, currentConfiguration.get('replicationinterval') * 1000)

	doReplicationFrom = () ->
		currentPouchDB = App.request("todolistapp:PouchDB");
		currentConfiguration = App.request("todolistapp:Configuration")
		
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
				# App.vent.trigger 'replication:pouchdb:from:uptodate'
				App.vent.trigger 'replication:pouchdb:from:uptodate'

			pouchdbRepFrom.on 'error', ()->
				pouchdbRepFrom.cancel()
				pouchdbRepFrom = undefined
				App.vent.trigger 'replication:pouchdb:from:error'
				if currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepFrom = setTimeout(doReplicationFrom, currentConfiguration.get('replicationinterval') * 1000)
			
			pouchdbRepFrom.on 'change', ()->
				App.vent.trigger 'replication:pouchdb:from:change'
			
			pouchdbRepFrom.on 'complete', () ->
				App.vent.trigger 'replication:pouchdb:from:complete'
				if not currentConfiguration.get('continuousreplication') and currentConfiguration.get('replicationinterval')? and currentConfiguration.get('replicationinterval') > 0
					timeOutRepFrom = setTimeout(doReplicationFrom, currentConfiguration.get('replicationinterval') * 1000)
		
		
	
	App.vent.on 'todolistapp:startReplication', () -> 
		doReplicationTo()
		doReplicationFrom()

	TodoListApp.run = -> 	
			window.TodoListApp
			App.vent.trigger('app:initialized', App)
		
	# TodoListApp.on 'all', (a)->
	# console.log 'TodoListApp events' + a

	App.addInitializer () ->
		TodoListApp.run()

