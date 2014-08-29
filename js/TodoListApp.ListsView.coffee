App.module 'TodoListApp.ListsView', (ListsView, App, Backbone, Marionette, $, _) ->

	class ListItemView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item"
		template : _.template """
		<%= name %> 
		<span class="delete badge" data-toggle="tooltip" data-placement="top" title="Lösche Adresse"><i class="fa fa-trash-o fa-fw"></i></span>
		"""
		initialize : ->
			@model.correspondingView = @
			
		events :
			'click .delete' : () ->
				@model.destroy()
		# onBeforeRender :  ->
		# 	console.debug @model.get('eMail')
		onRender : ->
			@$el.find('span').tooltip()
			return true

	class ListCollectionView extends Marionette.CollectionView
		tagName : "ul"
		className : "list-group"
		childView : ListItemView

	class ListCollection extends Backbone.Collection
		model : Backbone.Model

	@run = ->
		console.debug 'TodoListApp.ListsView'
		@mainView = new ListCollectionView({ collection : new ListCollection() })
		App.TodoListApp.mainView.listsView.show(@mainView)
		App.TodoListApp.listCollection = @mainView.collection
	
	App.addInitializer @run

