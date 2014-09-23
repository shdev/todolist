App.module 'TodoListApp.TopBar', (TopBar, App, Backbone, Marionette, $, _) ->

	
	class TopBarView extends Marionette.LayoutView
		template : _.template """
		<nav class="navbar navbar-default" role="navigation">
			<div class="container">
				<button type="button" class="btn btn-default sync-pouchdb navbar-btn" title="unsynced">
					<i class="fa fa-long-arrow-down text-muted"></i>
					<i class="fa fa-long-arrow-up text-muted"></i>
				</button> 
			</div><!-- /.container-fluid -->
		</nav>
		"""		
		hashTo : '.fa-long-arrow-up'
		hashFrom : '.fa-long-arrow-down'
		
		events : 
			'click button.sync-pouchdb' : () ->
				App.vent.trigger 'todolistapp:startReplication'
		normalizeTo : () ->
			@$(@hashTo).removeClass('text-success text-danger text-primary text-warning text-muted faa-flash animated')
		normalizeFrom : () ->
			@$(@hashFrom).removeClass('text-success text-danger text-primary text-warning text-muted faa-flash animated')
		mapDBEventToClass : (event, cssclass) ->
			eventHandler = () ->
				console.debug event + ' --- ' + cssclass
				@normalizeTo().addClass(cssclass)
				@$('.sync-pouchdb').attr('title', moment().format('llll'))
			App.vent.on event, eventHandler, @ 
		mapDBEventFromClass : (event, cssclass) ->
			eventHandler = () -> 
				console.debug event + ' --- ' + cssclass
				@normalizeFrom().addClass(cssclass)
				@$('.sync-pouchdb').attr('title', moment().format('llll'))
			App.vent.on event, eventHandler, @
		initialize : () ->
			@mapDBEventToClass 'replication:pouchdb:to:cancel', 'text-warning'
			@mapDBEventToClass 'replication:pouchdb:to:change', 'text-primary faa-flash animated'
			@mapDBEventToClass 'replication:pouchdb:to:error', 'text-danger'
			@mapDBEventToClass 'replication:pouchdb:to:complete', 'text-warning'
			@mapDBEventToClass 'replication:pouchdb:to:uptodate', 'text-success'
		
			@mapDBEventFromClass 'replication:pouchdb:from:cancel', 'text-warning'
			@mapDBEventFromClass 'replication:pouchdb:from:change', 'text-primary faa-flash animated'
			@mapDBEventFromClass 'replication:pouchdb:from:error', 'text-danger'
			@mapDBEventFromClass 'replication:pouchdb:from:complete', 'text-warning'
			@mapDBEventFromClass 'replication:pouchdb:from:uptodate', 'text-success'
			
	
	App.reqres.setHandler "TodoListApp:class:TopBarView", () ->
		TopBarView
	
	App.mainRegion.on 'before:show', (view) -> 
		console.debug "App.mainregion.on 'before:show'"
		console.debug view
		###
		TODO check with instanceof
		###
		TopBar.mainView = new TopBarView()
		view.topBar.show(TopBar.mainView)