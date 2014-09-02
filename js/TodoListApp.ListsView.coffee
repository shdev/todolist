App.module 'TodoListApp.ListsView', (ListsView, App, Backbone, Marionette, $, _) ->

	class ListItemView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item"
		cid : 'ListItemView'
		template : _.template """
		<span class="content"><%= name %></span>
		<span class="badge delete" data-toggle="tooltip" data-placement="top" title="Lösche Adresse"><i class="fa fa-trash-o fa-fw" ></i></span>
		"""
		behaviors :
			Tooltip : {}
		initialize : ->
			@model.correspondingView = @
			@model.on 'change', (a,b,c) -> 
				console.debug @cid 
				console.debug a  
				console.debug b
				console.debug c
				 
			
		events :
			'click .delete' : () ->
				@model.destroy()
				return false
			'click' : () ->
				if not @$el.hasClass('list-group-item-success')
					@$el.siblings().removeClass 'list-group-item-success'
					App.vent.trigger 'todolist:changelist', @model
		
		clicked : () ->
			@$el.addClass 'list-group-item-success'
		
		# onBeforeRender :  ->
		# 	console.debug @model.get('eMail')
		onRender : ->
			console.debug 'Render List: ' + @model.get('name') 
			return true

	class ListCollectionView extends Marionette.CollectionView
		tagName : "ul"
		className : "list-group"
		childView : ListItemView

	class ListModel extends Backbone.Model
		idAttribute : '_id'
		defaults : 
			type : 'todolist'
			created : JSON.parse(JSON.stringify(new Date()))
		sync: BackbonePouch.sync db : PouchDB('svh_todo', adapter : 'websql') 

	pouchdbOptions = 
		db : PouchDB('svh_todo', adapter : 'websql')
		fetch : 'query'
		options :
			query :
				include_docs: true
				fun :
					map : (doc) ->
						if doc.type == 'todolist'
							emit doc.position, null
			changes :
				include_docs: true,
				filter : (doc) ->
					return doc._deleted || doc.type == 'todolist'

	class ListCollection extends Backbone.Collection
		model : ListModel
		sync : BackbonePouch.sync pouchdbOptions
		parse : (result) ->
			return _.pluck(result.rows, 'doc')
		
		
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.ListItemView = ListItemView
	App.TodoListApp.classes.ListCollectionView = ListCollectionView
	App.TodoListApp.classes.ListCollection = ListCollection
	App.TodoListApp.classes.ListModel = ListModel

	ListsView.run = ->
		console.debug 'TodoListApp.ListsView'
		@mainView = new ListCollectionView({ collection : new ListCollection() })
		App.TodoListApp.mainView.listsView.show(@mainView)
		App.TodoListApp.listCollection = @mainView.collection
		@mainView.collection.fetch()
		
	ListsView.addInitializer ->
		@run()
		
	App.vent.on 'todolist:changelist', (todolistmodel) ->
		console.debug 'todolist:changelist ListsView'
		console.debug todolistmodel.id
		
		todolistmodel.correspondingView.clicked()
		
	
	ListsView.on "start", ->
		console.debug "ListView.onStart"
		return true
		
	ListsView.on 'all', (a)->
		console.log 'ListsView events' + a