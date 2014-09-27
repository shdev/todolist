App.module 'TodoListApp.ListsView', (ListsView, App, Backbone, Marionette, $, _) ->

	class NoEntrieView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item list-group-item-warning"
		template : _.template """
		Es gibt keine Einträge!
		"""
		
		###
		TODO watch out for the collection loads data
		###
		# behaviors :
		# 	Tooltip : {}
		onRender : ->
			console.debug 'Render NoEntrieView'

	class ListItemView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item"
		cid : 'ListItemView'
		template : _.template """
		<span class="content"><%= name %></span>
		<div class="delete"><div class="center">
				<i class="fa fa-fw fa-trash-o"></i>
		</div></div>
		<div class="no"><div class="center">
				<i class="fa fa-fw fa-ban"></i>
		</div></div>
		"""
		behaviors :
			Tooltip : {}
		initialize : ->
			@model.correspondingView = @
		events :
			'click .delete' : () ->
				if @$el.hasClass('delete-mode') 
					@model.destroy()
				else
					@$el.addClass 'delete-mode'
				false
			'click .no' : () ->
				@$el.removeClass 'delete-mode'
				false
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
			thisModel = @model
			@$(".content").editable
				type	: 'text'
				name	: 'Name eingeben'
				value	: @model.get('name')
				pk	: @model.get('id')
				url	: ''
				mode : 'inline'
				success	: (response, newValue) ->
					thisModel.set('name', newValue)
					thisModel.save()
			return true

	class ListCollectionView extends Marionette.CollectionView
		tagName : "ul"
		className : "list-group"
		childView : ListItemView
		emptyView : NoEntrieView

	class ListModel extends Backbone.Model
		idAttribute : '_id'
		defaults : () ->
			"app-name" : 'de.sh-dev.couchtodolist'
			username : App.request("TodoListApp:Configuration").get('username')
			type : 'todolist'
			created : JSON.parse(JSON.stringify(new Date()))
		sync: BackbonePouch.sync db : PouchDB('svh_todo', adapter : 'websql')
		initialize : () -> 
			@on 'destroy' , (a) -> 
				App.vent.trigger 'todolist:deleted-list', a.id if a? and a.id?

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
			# changes :
			# 	include_docs: true,
			# 	filter : (doc) ->
			# 		return doc._deleted || doc.type == 'todolist'

	class ListCollection extends Backbone.Collection
		model : ListModel
		sync : BackbonePouch.sync pouchdbOptions
		comparator : 'created'
		parse : (result) ->
			console.debug 'parse lists'
			console.debug result
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
		# @run()
		
	App.vent.on 'todolist:changelist', (todolistmodel) ->
		console.debug 'todolist:changelist ListsView'
		console.debug todolistmodel.id
		todolistmodel.correspondingView.clicked()

	listCollection = undefined
	
	refetchData = () ->
		listCollection.fetch() if listCollection?
		
	App.vent.on 'replication:pouchdb:to:complete', refetchData
	App.vent.on 'replication:pouchdb:to:uptodate', refetchData
	App.vent.on 'replication:pouchdb:from:uptodate', refetchData
	App.vent.on 'replication:pouchdb:from:complete', refetchData
	
	App.mainRegion.on 'before:show', (view) -> 
		console.debug "App.mainregion.on 'before:show'"
		console.debug view
		###
		TODO check with instanceof
		###
		ListsView.mainView = new ListCollectionView({ collection : new ListCollection() })
		view.listsView.show(ListsView.mainView)
		App.TodoListApp.listCollection = ListsView.mainView.collection
		ListsView.mainView.collection.fetch()
		
	
	ListsView.on "start", ->
		console.debug "ListView.onStart"
		return true
		
	ListsView.on 'all', (a)->
		console.log 'ListsView events' + a