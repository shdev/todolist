App.module 'TodoListApp.EntryInput', (EntryInput, App, Backbone, Marionette, $, _) ->

	
	class EntryInputView extends Marionette.LayoutView
		ui : 
			"addItemButton" : "button.add-item"
			"itemName" : "input"
		behaviors :
			AddSimpleItem : {}
		className : "form-group"
		template : _.template """
		<label for="entryname">Eintrag eintragen</label>
		<div class="input-group">
			<input type="text" class="form-control" id="entryname" placeholder="Eintrag">
			<span class="input-group-btn">
				<button class="btn btn-success add-item" type="button"><i class="fa fa-plus"></i></button>
			</span>
		</div>
		"""

	EntryInput.run = ->
			console.debug 'TodoListApp.EntryInput'
			@mainView = new EntryInputView()
			App.TodoListApp.mainView.entryInput.show(@mainView);
	
	EntryInput.addInitializer EntryInput.run
	