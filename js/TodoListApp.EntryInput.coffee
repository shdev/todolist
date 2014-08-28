App.module 'TodoListApp.EntryInput', (EntryInput, App, Backbone, Marionette, $, _) ->

	
	class MainView extends Marionette.LayoutView
#		className : "container"
		template : _.template """
		<input type="text" />
		"""
			

	EntryInput.run = ->
			console.debug 'TodoListApp.EntryInput'
			@mainView = new MainView()
			console.debug App
			console.debug App.TodoListApp
			App.TodoListApp.mainView.entryInput.show(@mainView);

#	App.vent.on "todolistapp:entryinput:init", EntryInput.run
	
	
	EntryInput.addInitializer EntryInput.run
	