	App.module 'TodoListApp.TopBar', (TopBar, App, Backbone, Marionette, $, _) ->
		class TopBarView extends Marionette.LayoutView
			template : _.template """
			<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
				<div class="container-fluid">
					<button type="button" class="btn btn-default sync-pouchdb navbar-btn pull-right" title="unsynced">
						<i class="fa fa-long-arrow-down text-muted"></i>
						<i class="fa fa-exclamation text-warning sync-needed"></i>
						<i class="fa fa-long-arrow-up text-muted"></i>
					</button>
					<button type="button" class="btn btn-default show-settings navbar-btn pull-right" title="Settings">
						<i class="fa fa-cogs fa-fw"></i>
					</button>
					<button type="button" class="btn btn-default show-lists navbar-btn pull-left active" title="Show Lists">
						<i class="fa fa-bars fa-fw"></i>
					</button>
					<p class="navbar-text list-name"></p>
				</div>
			</nav>
			"""		
			hashTo : '.fa-long-arrow-up'
			hashFrom : '.fa-long-arrow-down'
			hashSyncNeeded : '.sync-needed'
			events : 
				'click button.sync-pouchdb' : () ->
					App.vent.trigger 'todolistapp:startReplication'
				'click button.show-settings' : () ->
					App.vent.trigger 'todolist:configuration:hideview'
				'click button.show-lists' : () ->
					@$('button.show-lists').toggleClass('active')
					App.vent.trigger 'todolist:lists:show'
			normalizeTo : () ->
				@$(@hashTo).removeClass('text-success text-danger text-primary text-warning text-muted faa-flash animated')
			normalizeFrom : () ->
				@$(@hashFrom).removeClass('text-success text-danger text-primary text-warning text-muted faa-flash animated')
			mapDBEventToClass : (event, cssclass) ->
				eventHandler = () ->
					@normalizeTo().addClass(cssclass)
					@$('.sync-pouchdb').attr('title', moment().format('llll'))
				@listenTo App.vent, event, eventHandler
			mapDBEventFromClass : (event, cssclass) ->
				eventHandler = () -> 
					@normalizeFrom().addClass(cssclass)
					@$('.sync-pouchdb').attr('title', moment().format('llll'))
				@listenTo App.vent, event, eventHandler
			handlerForSyncNeededChange : (model) ->
				console.debug 'handlerForSyncNeededChange'
				console.debug model
				try
					if model.get('unsyncedListChanges') == 0 and model.get('unsyncedEntryChanges') == 0
						console.debug 'hide'
						@$(@hashSyncNeeded).addClass('hidden')
					else 
						console.debug 'unhide'
						@$(@hashSyncNeeded).removeClass('hidden')
				catch
					
			listChanged : (todolistmodel) ->
					@$('.list-name').text todolistmodel.get('name')
			listDeleted : (a) ->
				if App.TodoListApp.entryCollection?
					if a == App.TodoListApp.entryCollection["todolist-id"]
						@$('.list-name').text '<nix ausgewählt>'
				else
					@$('.list-name').text '<nix ausgewählt>'
			onRender : () ->
				@$('.list-name').text '<nix ausgewählt>'
				try
					@handlerForSyncNeededChange App.request("todolistapp:Configuration")
				catch
					
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
			
				@listenTo App.vent, 'todolist:deleted-list', @listDeleted
				@listenTo App.vent, 'todolist:changelist', @listChanged
				
				config = App.request("todolistapp:Configuration")
				
				if config?
					@listenTo config, "change:unsyncedListChanges", @handlerForSyncNeededChange
					@listenTo config, "change:unsyncedEntryChanges", @handlerForSyncNeededChange
	
		App.reqres.setHandler "todolistapp:class:TopBarView", () ->
			TopBarView
	
		App.mainRegion.on 'before:show', (view) -> 
			###
			TODO check with instanceof
			###
			TopBar.mainView = new TopBarView()
			view.topBar.show(TopBar.mainView)