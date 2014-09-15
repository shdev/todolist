App.module 'TodoListApp.Configuration', (Configuration, App, Backbone, Marionette, $, _) ->

	class TodoConfigurationModel extends Backbone.Model
		defaults : 
			continuousreplication : false # 
			username : "Rodosch"
			replicateurl : null
			replicationinterval : 5 * 60 * 1000
			deleteCheckedEntries : 5 * 24 *  60 * 60 
			deleteUnusedEntries : 24 *  60 * 60
		validate : (attributes, options) ->
			console.debug 'validate'
			console.debug attributes
			console.debug options
			if not attributes.username? or not _.isString(attributes.username) or attributes.username.trim().length = 0
				return  'username'
			attributes.username = attributes.username.trim()
			urlRegEx = /^(https?:\/\/)(?:\S+(?::\S*)?@)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/i
			
			if not attributes.replicateurl? or not _.isString(attributes.replicateurl) or attributes.replicateurl.trim().length = 0
				
			else 
				if not urlRegEx.test(attributes.replicateurl)
					return 'replicateurl'
					
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
				@model.save({username : @$('input.username').val().trim()})
			'change input.replicateurl' : () ->
				@model.save({replicateurl: @$('input.replicateurl').val().trim()})
			'change input.replicateurl' : () ->
				@model.save({replicateurl: @$('input.replicateurl').val().trim()})
			
		modelEvents : 
			'change' : () ->
				@setValues()
			'invalid' : () ->
				console.debug 'invalid'
				console.debug @model.validationError
		template : _.template """
			<div class="form-group has-error">
				<label class="control-label" for="username">Benutzername</label>
				<input type="text" class="form-control username" placeholder="Mein Name ist??" required />
			</div>
			<hr />
			<div class="form-group has-error">
				<label class="control-label" for="replicateurl">Adresse zum Replizieren</label>
				<input type="url" class="form-control replicateurl" placeholder="http://" required />
			</div>
			<div class="checkbox has-error">
				<label>
					<input type="checkbox" class="continuousreplication" required> Durchgängige Replikation
				</label>
			</div>
			<div class="form-group replicationinterval has-error">
				<label class="control-label" for="replicationinterval">Replikationsinterval</label>
				<div class="input-group">
					<input class="form-control replicationinterval" required type="number" min="0" step="3" placeholder="0" />
					<div class="input-group-btn">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
						<ul class="dropdown-menu dropdown-menu-right" role="menu">
							<li><a href="#" class="sek">sek</a></li>
							<li><a href="#" class="min">min</a></li>
							<li><a href="#" class="h">h</a></li>
						</ul>
					</div><!-- /btn-group -->
				</div>
			</div>
			<hr />
			<div class="form-group delete-checked-entries has-error">
				<label class="control-label" for="delete-checked-entries">Löschen von abgearbeiteten Einträgen nach</label>
				<div class="input-group">
					<input type="number" class="form-control delete-checked-entries">
					<div class="input-group-btn">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
						<ul class="dropdown-menu dropdown-menu-right" role="menu">
							<li><a href="#" class="sek">sek</a></li>
							<li><a href="#" class="min">min</a></li>
							<li><a href="#" class="h">h</a></li>
						</ul>
					</div><!-- /btn-group -->
				</div><!-- /input-group -->
			</div><!-- /form-group -->
			<div class="form-group delete-unused-entries has-error">
				<label class="control-label" for="delete-unused-entries">Löschen von ungenutzen Einträgen nach</label>
				<div class="input-group">
					<input type="number" class="form-control delete-unused-entries">
					<div class="input-group-btn">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
						<ul class="dropdown-menu dropdown-menu-right" role="menu">
							<li><a href="#" class="sek">sek</a></li>
							<li><a href="#" class="min">min</a></li>
							<li><a href="#" class="h">h</a></li>
						</ul>
					</div><!-- /btn-group -->
				</div><!-- /input-group -->
			</div><!-- /form-group -->

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
	