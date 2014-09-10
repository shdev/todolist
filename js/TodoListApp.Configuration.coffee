App.module 'TodoListApp.Configuration', (Configuration, App, Backbone, Marionette, $, _) ->

	class TodoConfiguration extends Backbone.Collection
		localStorage: new Backbone.LocalStorage("TodoListApp")
		defaults : 
			continuousreplication : false
			username : "Rodosch"
			replicateurl : "http://host:port/database"
			replicationinterval : 5 * 60 * 1000

	Configuration.todoConfiguration = {}

	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoConfiguration = TodoConfiguration

	Configuration.run = ->
		console.debug 'TodoListApp.Configuration.run'
		Configuration.todoConfiguration = new TodoConfiguration()
		App.reqres.setHandler "TodoListApp:Configuration", () ->
			Configuration.todoConfiguration

		Configuration.todoConfiguration.fetch().done ->
			App.vent.trigger 'todolist:configurationloaded', Configuration.todoConfiguration

	Configuration.addInitializer () -> 
		Configuration.run()
	