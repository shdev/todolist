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

	TodoListApp.run = -> 
			@mainView = new TodoListAppView()
			window.TodoListApp = @
			App.mainRegion.show(@mainView);
			App.vent.trigger('app:initialized', App)
			
	App.addInitializer ->
		TodoListApp .run()

