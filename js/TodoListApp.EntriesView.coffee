App.module 'TodoListApp.EntriesView', (EntriesView, App, Backbone, Marionette, $, _) ->

	class MainView extends Marionette.LayoutView
		className : "container"
		template : _.template """
			<div id="todolistapp-lists">
				<div id="todolistapp-list-input"></div>
				<div id="todolistapp-lists-view"></div>
			</div>
			<div id="todolistapp-entries">
				<div id="todolistapp-entry-input"></div>
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

	EntriesView.run -> 
			@mainView = new MainView()
			window.mainView = @mainView
			
			App.mainRegion.show(@mainView);

			console.debug 'todolistapp:listsview:init'
			App.vent.trigger('todolistapp:listsview:init', App)
			console.debug 'todolistapp:listinput:init'
			App.vent.trigger('todolistapp:listinput:init', App)
			
			
			console.debug 'todolistapp:entriesview:init'
			App.vent.trigger('todolistapp:entriesview:init', App)
			console.debug 'todolistapp:entryinput:init'
#			App.vent.trigger('todolistapp:entryinput:init', App)
			
			App.vent.trigger('app:initialized', App)
			
	App.addInitializer ->
		TodoListApp .run()

	EntriesView.on 'all', (a)->
		console.log 'EntriesView events' + a

