	App.module 'TodoListApp.ListsView', (ListsView, App, Backbone, Marionette, $, _) ->

		DescSort = (attribute) ->
			(a, b) ->
				aDate = a.get(attribute)
				bDate = b.get(attribute)
				if aDate == bDate 
					0
				else
					if aDate > bDate
						-1
					else
						1

		class NoEntrieView extends Marionette.ItemView
			tagName : "li"
			className : "list-group-item list-group-item-warning"
			getTemplate: () ->
				if !!@model.get('fetchingListData')
					_.template """
						<i class="fa fa-circle-o-notch fa-spin"></i> Es werden gerade Daten geladen!
						"""
				else
					_.template """
						Es gibt keine Einträge!
					"""
			modelEvents :
				'change:fetchingListData' : 'listFetchStatusChanged'
			###
			TODO watch out for the collection loads data
			###
			# behaviors :
			# 	Tooltip : {}
			listFetchStatusChanged : () ->
				@render()

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
					if not @$el.hasClass('list-group-item-info')
						@$el.siblings().removeClass 'list-group-item-info'
						App.vent.trigger 'todolist:changelist', @model
			modelEvents :
				'destroy' : (a) -> 
					App.vent.trigger 'todolist:deleted-list', a.id if a? and a.id?
				
			clicked : () ->
				@$el.addClass 'list-group-item-info'
		
			# onBeforeRender :  ->
			#  	console.debug @model.get('name')
			#
			onRender : ->
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
			onDestroy : () ->
				@model.correspondingView = null

		class ListCollectionView extends Marionette.CollectionView
			tagName : "ul"
			className : "list-group"
			childView : ListItemView
			emptyView : NoEntrieView
			collectionEvents :
				'remove' : (a) -> 
					App.vent.trigger 'todolist:deleted-list', a.id if a? and a.id?
				'request' : () ->
					App.request("todolistapp:Configuration").set('fetchingListData', true)
				'sync' : () -> 
					App.request("todolistapp:Configuration").set('fetchingListData', false)
			resortView : () ->
				elem = @$el
				if 0 < @collection.length
					for oneModel in @collection.models
						do (oneModel) ->
							elem.append oneModel.correspondingView.$el
			sortCollectionDateAsc : () ->
				@collection.comparator = "created"
				@collection.sort()
			sortCollectionDateDesc : () ->
				@collection.comparator = DescSort 'created'
				@collection.sort()
			
			sortCollectionNameAsc : () ->
				@collection.comparator = "name"
				@collection.sort()
			sortCollectionNameDesc : () ->
				@collection.comparator = DescSort 'name'
				@collection.sort()
			
			sortCollectionAmountAsc : () ->
				@collection.comparator = "_id"
				@collection.sort()
			sortCollectionAmountDesc : () ->
				@collection.comparator = DescSort '_id'
			
			initialize : () ->
				@listenTo App.vent, "todolist:lists:sort:date:asc", @sortCollectionDateAsc
				@listenTo App.vent, "todolist:lists:sort:date:desc", @sortCollectionDateDesc
			
				@listenTo App.vent, "todolist:lists:sort:name:asc", @sortCollectionNameAsc
				@listenTo App.vent, "todolist:lists:sort:name:desc", @sortCollectionNameDesc
			
				@listenTo App.vent, "todolist:lists:sort:amount:asc", @sortCollectionAmountAsc
				@listenTo App.vent, "todolist:lists:sort:amount:desc", @sortCollectionAmountDesc

		pouchdb = App.request("todolistapp:PouchDB")

		class ListModel extends Backbone.Model
			idAttribute : '_id'
			defaults : () ->
				"app-name" : 'de.sh-dev.couchtodolist'
				username : App.request("todolistapp:Configuration").get('username')
				type : 'todolist'
				created : JSON.parse(JSON.stringify(new Date()))
			sync: BackbonePouch.sync db : pouchdb
			initialize : () -> 

				
		pouchdbOptions = 
			db : pouchdb
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
			comparator : 'name'
			parse : (result) ->
				return _.pluck(result.rows, 'doc')

		
		App.TodoListApp.classes = {} if not App.TodoListApp.classes?
		App.TodoListApp.classes.ListItemView = ListItemView
		App.TodoListApp.classes.ListCollectionView = ListCollectionView
		App.TodoListApp.classes.ListCollection = ListCollection
		App.TodoListApp.classes.ListModel = ListModel
		
		App.vent.on 'todolist:changelist', (todolistmodel) ->
			todolistmodel.correspondingView.clicked()

		listCollection = undefined
	
		refetchData = () ->
			App.TodoListApp.listCollection.fetch() if (not App.request("todolistapp:Configuration").get('fetchingListData')) and App.TodoListApp.listCollection?
		
		App.vent.on 'replication:pouchdb:to:complete', refetchData
		App.vent.on 'replication:pouchdb:to:uptodate', refetchData
		App.vent.on 'replication:pouchdb:from:uptodate', refetchData
		App.vent.on 'replication:pouchdb:from:complete', refetchData
		App.vent.on 'todolistapp:startReplication', refetchData
		App.vent.on 'todolistapp:pouchdb:destroyed', refetchData
	
		App.mainRegion.on 'before:show', (view) -> 
			listCollectionViewOptions =
				collection : new ListCollection()
				emptyViewOptions : 
					model : App.request("todolistapp:Configuration")
			ListsView.mainView = new ListCollectionView(listCollectionViewOptions)
			view.listsView.show(ListsView.mainView)
			App.TodoListApp.listCollection = ListsView.mainView.collection
			ListsView.mainView.collection.fetch()