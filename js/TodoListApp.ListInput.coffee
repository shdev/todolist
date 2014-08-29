App.module 'TodoListApp.ListInput', (ListInput, App, Backbone, Marionette, $, _) ->

	class ListInputView extends Marionette.LayoutView
#		className : "input-group"
		ui : 
			"addItemButton" : "button.add-item"
			"itemName" : "input"
		behaviors :
			AddSimpleItem : {}
		getCollection : ->
			return App.TodoListApp.listCollection
		template : _.template """
		<label for="listname">Liste anlegen</label>
		<div class="input-group">
			<input type="text" class="form-control" id="listname" placeholder="Liste">
			<span class="input-group-btn">
				<button class="btn btn-success add-item" type="button"><i class="fa fa-plus"></i></button>
			</span>
		</div>
		"""

	ListInput.run = ->
			console.debug 'TodoListApp.ListInput'
			@mainView = new ListInputView()
			App.TodoListApp.mainView.listInput.show(@mainView);

	ListInput.addInitializer ListInput.run
