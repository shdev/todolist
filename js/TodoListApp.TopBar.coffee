App.module 'TodoListApp.TopBar', (TopBar, App, Backbone, Marionette, $, _) ->

	
	class TopBarView extends Marionette.LayoutView
		template : _.template """
		<nav class="navbar navbar-default" role="navigation">
		   <div class="navbar-header">
		      <a class="navbar-brand" href="#">TutorialsPoint</a>
		   </div>
		   <div>
		      <p class="navbar-text">Signed in as Thomas</p>
		   </div>
		</nav>
		
			<nav class="navbar navbar-default" role="navigation">
				<div class="container">
					<!-- Brand and toggle get grouped for better mobile display -->
					<div class="navbar-header">
						<a class="navbar-brand" href="#"></a>
						<p class="navbar-text">
							<button type="button" class="btn btn-default sync-pouchdb">
								<i class="fa fa-long-arrow-down text-muted"></i>
								<i class="fa fa-long-arrow-up text-muted"></i>
									
							</button> Signed in as <a href="#" class="navbar-link">
														Mark Otto
													</a>
						</p>

					</div>
				</div><!-- /.container-fluid -->
			</nav>
		"""
		###
		replication:pouchdb:to:cancel
		replication:pouchdb:to:uptodate
		replication:pouchdb:to:error
		replication:pouchdb:to:complete
		
		replication:pouchdb:from:cancel
		replication:pouchdb:from:uptodate
		replication:pouchdb:from:error
		replication:pouchdb:from:complete
		###
		
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
			App.vent.on event, eventHandler, @ 
		mapDBEventFromClass : (event, cssclass) ->
			eventHandler = () -> 
				console.debug event + ' --- ' + cssclass
				@normalizeFrom().addClass(cssclass)
			App.vent.on event, eventHandler, @
		initialize : () ->
			@mapDBEventToClass 'replication:pouchdb:to:cancel', 'text-warning'
			@mapDBEventToClass 'replication:pouchdb:to:change', 'text-primary faa-flash animated'
			@mapDBEventToClass 'replication:pouchdb:to:error', 'text-danger'
			@mapDBEventToClass 'replication:pouchdb:to:complete', 'text-success'
		
			@mapDBEventFromClass 'replication:pouchdb:from:cancel', 'text-warning'
			@mapDBEventFromClass 'replication:pouchdb:from:change', 'text-primary faa-flash animated'
			@mapDBEventFromClass 'replication:pouchdb:from:error', 'text-danger'
			@mapDBEventFromClass 'replication:pouchdb:from:complete', 'text-success'
			
	
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