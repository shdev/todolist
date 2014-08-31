App.module 'TodoListApp.EntryInput', (EntryInput, App, Backbone, Marionette, $, _) ->

	
	class EntryInputView extends Marionette.LayoutView
		ui : 
			"addItemButton" : "button.add-item"
			"itemName" : "input"
		behaviors :
			AddSimpleItem : {}
			
		managedCollection : ->
			return App.TodoListApp.entryCollection
		modelClass : ->
			return App.TodoListApp.classes.EntryModel
			
		className : "form-group"
		template : _.template """
			<label for="entryname">Eintrag eintragen</label>
			<form>
				<div class="input-group">
					<input type="text" class="form-control" id="entryname" placeholder="Eintrag">
					<span class="input-group-btn">
						<button class="btn btn-success add-item" type="submit"><i class="fa fa-plus"></i></button>
					</span>
				</div>
			</form>
		"""
	
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.EntryInputView = EntryInputView

	EntryInput.run = ->
			console.debug 'TodoListApp.EntryInput.run'
			@mainView = new App.TodoListApp.classes.EntryInputView()
			App.TodoListApp.mainView.entryInput.show(@mainView);
	
	EntryInput.on 'all', (a)->
		console.log 'EntryInput events' + a
	
	EntryInput.addInitializer EntryInput.run
	