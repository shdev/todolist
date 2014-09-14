App.module 'TodoListApp.Configuration', (Configuration, App, Backbone, Marionette, $, _) ->

	class TodoConfigurationModel extends Backbone.Model
		defaults : 
			continuousreplication : false
			username : "Rodosch"
			replicateurl : null
			replicationinterval : 5 * 60 * 1000
		validate : (attributes, options) ->
			console.debug 'validate'
			console.debug attributes
			console.debug options
			if not attributes.username? or not _.isString(attributes.username) or attributes.username.trim().length = 0
				return  'username'
			attributes.username = attributes.username.trim()
			@set({username : attributes.username.trim()}, {silent : true})
			urlRegEx = /^(https?:\/\/)(?:\S+(?::\S*)?@)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/i
			
			if not attributes.replicateurl? or not _.isString(attributes.replicateurl) or attributes.replicateurl.trim().length = 0
				@set({replicateurl : null}, {silent : true})
			else 
				if not urlRegEx.test(attributes.replicateurl)
					return 'replicateurl'

			if not attributes.continuousreplication? or not _.isBoolean(attributes.continuousreplication)
				@set({continuousreplication : false }, {silent : false})
					
			undefined
			
	class TodoConfigurationCollection extends Backbone.Collection
		localStorage: new Backbone.LocalStorage("TodoListApp")
		model : TodoConfigurationModel

	Configuration.todoConfiguration = {}

	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.TodoConfigurationCollection = TodoConfigurationCollection
	App.TodoListApp.classes.TodoConfigurationModel = TodoConfigurationModel

	class ConfigurationView extends Marionette.LayoutView
		tagName : "form"
		setValues : () ->
			console.debug 'ConfigurationView.setValues'
			console.debug @model.toJSON()
			
			console.debug @$('input.username')
			@$('input.username').val(@model.get('username'))
			console.debug @$('input.replicateurl')
			@$('input.replicateurl').val(@model.get('replicateurl'))
			console.debug @$('input.continuousreplication')
			@$('input.continuousreplication').val(@model.get('continuousreplication'))
			console.debug @$('input.replicationinterval')
			@$('input.replicationinterval').val(@model.get('replicationinterval'))
		events : 
			'change input.username' : () ->
				@model.save({username : @$('input.username').val()})
			'change input.replicateurl' : () ->
				@model.save({replicateurl: @$('input.replicateurl').val()})
		modelEvents : 
			'change' : () ->
				@setValues()
			'invalid' : () ->
				console.debug 'invalid'
				console.debug @model.validationError
		template : _.template """
			<div class="form-group">
				<label for="username">Benutzername</label>
				<input type="text" class="form-control username" placeholder="Mein Name ist??" required />
			</div>
			<hr />
			<div class="form-group">
				<label for="replicateurl">Adresse zum Replizieren</label>
				<input type="url" class="form-control replicateurl" placeholder="http://" required />
			</div>
			<div class="checkbox">
				<label>
					<input type="checkbox" class="continuousreplication" required> Durchgängige Replikation
				</label>
			</div>
			<div class="form-group replicationinterval">
				<label for="replicationinterval">Replikationsinterval</label>
				<div class="input-group">
					<input class="form-control replicationinterval" required type="number" min="0" step="3" placeholder="0" />
					<div class="input-group-addon">sek</div>
				</div>
			</div>
			<hr />
			<button type="reset" class="btn btn-warning">Zurücksetzen</button>
			<button type="submit" class="btn btn-primary">Speichern</button>
		"""
		onRender : () ->
			@setValues()
	configurationLoaded = ->
		App.vent.trigger 'todolist:configurationloaded', Configuration.todoConfiguration
			
	configurationErrorOnLoad = ->
			App.vent.trigger 'todolist:configurationerroronload'


	Configuration.run = ->
		console.debug 'TodoListApp.Configuration.run'
		Configuration.todoConfiguration = new TodoConfigurationCollection()
		App.reqres.setHandler "TodoListApp:Configuration", () ->
			if Configuration.todoConfiguration.length == 0
				Configuration.todoConfiguration.add(new TodoConfigurationModel())
				Configuration.todoConfiguration.at(0).save(null, {wait: true})
				Configuration.todoConfiguration.at(0).on 'change', ->
					Configuration.todoConfiguration.at(0).save()
			
			console.debug Configuration.todoConfiguration
			console.debug Configuration.todoConfiguration.at(0)
			
			Configuration.todoConfiguration.at(0)

		Configuration.todoConfiguration.fetch({wait: true}).done(configurationLoaded).fail(configurationErrorOnLoad) 
		
	App.mainRegion.on 'before:show', (view) -> 
		console.debug "App.mainregion.on 'before:show'"
		console.debug view
		###
		TODO check with instanceof
		###
		Configuration.mainView = new ConfigurationView({model : Configuration.todoConfiguration.at(0)})
		view.configurationView.show(Configuration.mainView)
	

	Configuration.addInitializer () -> 
		Configuration.run()
	