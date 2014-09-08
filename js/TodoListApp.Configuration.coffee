App.module 'TodoListApp.Configuration', (Configuration, App, Backbone, Marionette, $, _) ->
	
	class TodoConfiguration extends Backbone.Collection
		localStorage: new Backbone.LocalStorage("TodoListApp")
		
	
	Configuration.todoConfiguration = {}



	# var groceryList = MyApp.reqres.request("todoList", "groceries");
	#
	# var groceryList = MyApp.request("todoList", "groceries");
	
	
		
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoConfiguration = TodoConfiguration

	Configuration.run = ->
		console.debug 'TodoListApp.Configuration.run'
		Configuration.todoConfiguration = new TodoConfiguration()
		App.reqres.setHandler "TodoListApp:Configuration", () ->
			Configuration.todoConfiguration

		Configuration.todoConfiguration.fetch().done ->
			App.vent.trigger 'todolist:configurationloaded'
	
	
	Configuration.addInitializer () -> 
		Configuration.run()
	