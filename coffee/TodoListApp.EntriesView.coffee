	App.module 'TodoListApp.EntriesView', (EntriesView, App, Backbone, Marionette, $, _) ->

		class NoEntryView extends Marionette.ItemView
			tagName : "li"
			className : "list-group-item list-group-item-warning no-entry-view"
			getTemplate: () ->
				if !!@model.get('fetchingEntryData')
					_.template """
						<i class="fa fa-circle-o-notch fa-spin"></i> Es werden gerade Daten geladen!
					"""
				else
					_.template """
						Es gibt keine Einträge!
					"""
			modelEvents :
				'change:fetchingEntryData' : 'entryFetchStatusChanged'
			
			###
			TODO watch out for the collection loads data
			###
			# behaviors :
			# 	Tooltip : {}
			# onRender : ->
			entryFetchStatusChanged : () ->
				@render()
			# initialize : () ->

		class EntryItemView extends Marionette.ItemView
			tagName : "li"
			className : "list-group-item todolist-entry"
			template : _.template """
			<div class="checkbox">
				<div class="center">
					<i class="fa fa-fw fa-check"></i>
				</div>
			</div>
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
			
			modelEvents :
				"change:checked" : 'renderCheckStatus'
				"change:name" : 'reRenderName'
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
				'click .checkbox' : () ->
					@model.toggleCheck() 
					@model.save()
					false
				'click' : () ->
					if not @$el.hasClass('list-group-item-info')
						@$el.siblings().removeClass 'list-group-item-info'
						@$el.siblings().find('.editable').editable('destroy')
						@$el.addClass('list-group-item-info')
						thisModel = @.model
						@$(".content").editable
							type	: 'text'
							name	: 'Name eingeben'
							value	: @model.get('name')
							pk	: @model.get('id')
							url	: ''
							mode : 'inline'
							success	: (response, newValue) ->
								thisModel.set('name', newValue)
								try 
									App.request("todolistapp:Configuration").incEntryChanges()
								catch
									console.error 'Error configuration operation'
								thisModel.save()
							@renderCheckStatus()

			# onBeforeRender :  ->
			# 	console.debug @model.get('eMail')
			reRenderName : ->
				@$('.content').text @model.get('name')
			renderCheckStatus : ->
				if @model.get('checked')?
					@$el.addClass 'ischecked'
				else
					@$el.removeClass 'ischecked'
			onRender : ->
				thisModel = @model

				@renderCheckStatus()
				return true
			onDestroy : () ->
				@model.correspondingView = null
			
		class EntryCollectionView extends Marionette.CollectionView
			tagName : "ul"
			className : "list-group todolist-entries-list"
			childView : EntryItemView
			emptyView : NoEntryView
			collectionEvents : 
				'request' : ()->
					App.request("todolistapp:Configuration").set('fetchingEntryData', true)
				'sync' : () ->
					App.request("todolistapp:Configuration").set('fetchingEntryData', false)

			sortCollectionDateAsc : () ->
				@collection.comparator = @collection.sortFun "created", "asc"
				@collection.sort()
			sortCollectionDateDesc : () ->
				@collection.comparator = @collection.sortFun "created", "desc"
				@collection.sort()
			
			sortCollectionNameAsc : () ->
				@collection.comparator = @collection.sortFun "name", "asc"
				@collection.sort()
			sortCollectionNameDesc : () ->
				@collection.comparator = @collection.sortFun "name", "desc"
				@collection.sort()
			changeStyle : (model,value) ->
				if 'inline' == value
					@$el.addClass('list-inline')
				else
					@$el.removeClass('list-inline')
			changeSort : (model,sortType) ->
				switch sortType 
					when "nameAsc"
						@sortCollectionNameAsc()
					when "nameDesc"
						@sortCollectionNameDesc()
					when "dateAsc"
						@sortCollectionDateAsc()
					when "dateDesc"
						@sortCollectionDateDesc()
			toggleShowChecked : (model,value) ->
				if value
					@$el.removeClass('hide-checked')
				else
					@$el.addClass('hide-checked')
					
			onRender : () ->
				config = App.request("todolistapp:Configuration")
				@changeStyle(config, config.get('entryStyle'))
				@toggleShowChecked(config, config.get('entryShowChecked'))
				@changeSort(config, config.get('entrySort'))
				
			initialize : () ->
				config = App.request("todolistapp:Configuration")
				if config?
					@listenTo config, "change:entryStyle", @changeStyle
					@listenTo config, "change:entryShowChecked", @toggleShowChecked
					@listenTo config, "change:entrySort", @changeSort

		EntryModelFactory = (todolistid) -> 
			pouchdb = App.request("todolistapp:PouchDB")
			class EntryModel extends Backbone.Model
				idAttribute : '_id'
				defaults : () ->
					"app-name" : 'de.sh-dev.couchtodolist'
					username : App.request("todolistapp:Configuration").get('username')
					type : 'todoentry'
					created : JSON.parse(JSON.stringify(new Date()))
					"todolist-id" : todolistid
					checked : null
				sync : BackbonePouch.sync db:pouchdb
				check : () ->
					if not @get('checked')?
						@.set('checked', JSON.parse(JSON.stringify(new Date())))
				unCheck : ->
					if @get('checked')?
						@.set('checked', null)
				toggleCheck : ->
					if @get('checked')?
						@unCheck()
					else
						@check()
			return EntryModel
		
		
		EntryCollectionFactory = (todolistid) ->		
		
			pouchdb = App.request("todolistapp:PouchDB")
			mapfunc =  (doc) ->
				if doc.type? and doc["todolist-id"]?
					emit doc["todolist-id"], doc.pos if doc.type == 'todoentry'
			pouchdbOptions = 
				db : pouchdb
				fetch : 'query'
				options :
					query :
						include_docs: true
						fun :
							map : mapfunc
						key : todolistid
					# changes :
					# 	include_docs: true,
					# 	filter : (doc) ->
					# 		return doc._deleted || doc.type == 'todoentry'
						
			class EntryCollection extends Backbone.Collection
				sortFun : (attribute, direction) ->
					if direction.toLowerCase() == 'desc'
						(a, b) ->
							if (a.get('checked') == null and b.get('checked') == null) or (a.get('checked') != null and b.get('checked') != null)
								aDate = a.get(attribute).toString().toLowerCase()
								bDate = b.get(attribute).toString().toLowerCase()
								if aDate == bDate 
									0
								else
									if aDate > bDate
										-1
									else
										1
							else
								if a.get('checked') == null and b.get('checked') != null
									-1
								else
									1
					else
						(a, b) ->
							if (a.get('checked') == null and b.get('checked') == null) or (a.get('checked') != null and b.get('checked') != null)
								aDate = a.get(attribute).toString().toLowerCase()
								bDate = b.get(attribute).toString().toLowerCase()
								if aDate == bDate 
									0
								else
									if aDate > bDate
										1
									else
										-1
							else
								if a.get('checked') == null and b.get('checked') != null
									-1
								else
									1
				model : EntryModelFactory(todolistid)
				sync : BackbonePouch.sync pouchdbOptions
				"todolist-id" : todolistid
				comparator : 'created'
				parse : (result) ->
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
		
		refetchData = () ->
			App.TodoListApp.entryCollection.fetch() if (not App.request("todolistapp:Configuration").get('fetchingEntryData')) and App.TodoListApp.entryCollection?
		
		App.vent.on 'replication:pouchdb:to:complete', refetchData
		App.vent.on 'replication:pouchdb:to:uptodate', refetchData
		App.vent.on 'replication:pouchdb:from:uptodate', refetchData
		App.vent.on 'replication:pouchdb:from:complete', refetchData
		App.vent.on 'todolistapp:startReplication', refetchData
	
		# EntriesView.on "start", ->
		# 	return true		
		# EntriesView.on 'all', (a)->

		App.vent.on 'todolist:deleted-list' , (a) ->
			if App.TodoListApp.entryCollection?
				if a == App.TodoListApp.entryCollection["todolist-id"]
					App.TodoListApp.mainView.entriesView.reset()
					App.TodoListApp.mainView.entryInput.reset()	
					App.TodoListApp.entryCollection = null

		App.vent.on 'todolist:changelist', (todolistmodel) ->
			todolistid = todolistmodel.id
			App.TodoListApp.EntryInput.run() if !App.TodoListApp.mainView.entryInput.hasView()
			App.TodoListApp.classes.EntryModel = App.TodoListApp.classes.EntryModelFactory(todolistid)
			App.TodoListApp.classes.EntryCollection = App.TodoListApp.classes.EntryCollectionFactory(todolistid)
		
			entryCollectionViewOptions =
				collection : new App.TodoListApp.classes.EntryCollection(todolistid)
				emptyViewOptions : 
					model : App.request("todolistapp:Configuration")
			EntriesView.mainView = new EntryCollectionView(entryCollectionViewOptions)
	#		Why should I do this??
			EntriesView.mainView.collection.reset()
			App.TodoListApp.mainView.entriesView.show(EntriesView.mainView)
			App.TodoListApp.entryCollection = EntriesView.mainView.collection
			EntriesView.mainView.collection.fetch()
			return undefined
