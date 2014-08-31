App.module 'TodoListApp.EntriesView', (EntriesView, App, Backbone, Marionette, $, _) ->

	class EntryItemView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item"
		template : _.template """
		<%= name %> 
		<span class="delete badge" data-toggle="tooltip" data-placement="top" title="Lösche Adresse"><i class="fa fa-trash-o fa-fw"></i></span>
		"""
		behaviors :
			Tooltip : {}
		initialize : ->
			@model.correspondingView = @
			
		events :
			'click .delete' : () ->
				@model.destroy()
				return false
			'click' : () ->
				@$el.siblings().removeClass 'list-group-item-success'
				@$el.addClass 'list-group-item-success'
		# onBeforeRender :  ->
		# 	console.debug @model.get('eMail')
		onRender : ->
			console.debug 'Render Entry: ' + @model.get('name') 
			return true

	class EntryCollectionView extends Marionette.CollectionView
		tagName : "ul"
		className : "list-group"
		childView : EntryItemView



	EntryModelFactory = (todolistid) -> 
		class EntryModel extends Backbone.Model
			idAttribute : '_id'
			defaults : 
				type : 'todoentry'
				created : (new Date()).toUTCString()
				"todolist-id" : todolistid
			sync: BackbonePouch.sync db : PouchDB('svh_todo', adapter : 'websql')
		return EntryModel
	
	EntryCollectionFactory = (hasenbrot) ->
		console.debug 'EntryCollectionFactory:' + hasenbrot
		console.debug(typeof(hasenbrot))
		
		mapfunc =  (doc, emit) ->
			console.debug 'map entry'
			console.debug doc
			console.debug hasenbrot
			
			if doc.type? and doc["todolist-id"]?			
				if doc.type == 'todoentry'  and doc["todolist-id"] == hasenbrot
					emit [doc.position], null
								
		
		pouchdbOptions = 
			db : PouchDB('svh_todo', adapter : 'websql')
			fetch : 'query'
			options :
				query :
					include_docs: false
					fun :
						map : mapfunc
				changes :
					include_docs: true,
					filter : (doc) ->
						return doc._deleted || doc.type == 'todoentry'
						
		console.debug pouchdbOptions

		class EntryCollection extends Backbone.Collection
			model : EntryModelFactory(hasenbrot)
			sync : BackbonePouch.sync pouchdbOptions
			parse : (result) ->
				
				console.debug 'parse'
				
				console.debug result
				
				return _.pluck(result.rows, 'doc')
		
		return EntryCollection
		
		
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.EntryItemView = EntryItemView
	App.TodoListApp.classes.EntryCollectionView = EntryCollectionView
	App.TodoListApp.classes.EntryCollectionFactory = EntryCollectionFactory
	App.TodoListApp.classes.EntryModelFactory = EntryModelFactory
	App.TodoListApp.classes.EntryModel = undefined
	App.TodoListApp.classes.EntryCollection = undefined

	EntriesView.run = ( )->
		App.TodoListApp.entryCollection = undefined

		
	EntriesView.addInitializer ->
		EntriesView.run()
	
	EntriesView.on "start", ->
		console.debug "EntriesView.onStart"
		return true
		
	EntriesView.on 'all', (a)->
		console.log 'EntriesView events' + a

	App.commands.setHandler "showEntriesView" , (todolistid) ->
		console.debug 'TodoListApp.EntriesView with todolistid:' + todolistid
		App.TodoListApp.classes.EntryModel = App.TodoListApp.classes.EntryModelFactory(todolistid)
		console.debug 'App.TodoListApp.classes.EntryModel = EntryModelFactory(todolistid)'
		App.TodoListApp.classes.EntryCollection = App.TodoListApp.classes.EntryCollectionFactory(todolistid)
		console.debug 'App.TodoListApp.classes.EntryCollection = EntryCollectionFactory(todolistid)'
			
		EntriesView.mainView = new EntryCollectionView({ collection : new App.TodoListApp.classes.EntryCollection(todolistid) })
		console.debug 'EntriesView.mainView = new EntryCollectionView({ collection : new EntryCollectionFactory(todolistid) })'
		App.TodoListApp.mainView.entriesView.show(EntriesView.mainView)
		console.debug 'App.TodoListApp.mainView.entriesView.show(EntriesView.mainView)'
		App.TodoListApp.entryCollection = EntriesView.mainView.collection
		console.debug 'App.TodoListApp.entryCollection = EntriesView.mainView.collection'
		EntriesView.mainView.collection.fetch()
		console.debug 'EntriesView.mainView.collection.fetch()'
		return undefined