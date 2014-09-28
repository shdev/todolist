App.module 'TodoListApp.ListInput', (ListInput, App, Backbone, Marionette, $, _) ->
	class ListInputView extends Marionette.LayoutView
		className : "form-group"
		ui : 
			"addItemButton" : "button.add-item"
			"itemName" : "input"
		behaviors :
			AddSimpleItem : {}
		managedCollection : ->
			return App.TodoListApp.listCollection
		modelClass : ->
			return App.TodoListApp.classes.ListModel
		template : _.template """
			<label class="control-label" for="listname">Liste anlegen</label>
			<form>
			<div class="input-group">
				<input type="text" class="form-control" id="listname" placeholder="Liste">
				<span class="input-group-btn">
					<button class="btn btn-success add-item" type="submit"><i class="fa fa-plus"></i></button>
				</span>
			</div>
			</form>
		"""
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.ListInputView = ListInputView
	
	ListInput.run = ->
			@mainView = new ListInputView()
			App.TodoListApp.mainView.listInput.show(@mainView);

	App.mainRegion.on 'before:show', (view) -> 
		###
		TODO check with instanceof
		###
		ListInput.mainView = new ListInputView()
		view.listInput.show(ListInput.mainView)

	# ListInput.on 'all', (a)->
	# 	console.log 'ListInput events' + a

	ListInput.addInitializer ->
		# ListInput.run()
