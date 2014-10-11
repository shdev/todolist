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
			<form>
				<label for="entryname">Eintrag eintragen</label>
				<div class="input-group">
					<span class="input-group-btn">
						<button class="btn btn-default toggle-entry-options" type="button"><i class="fa fa-tasks"></i></button>
					</span>
					<input type="text" class="form-control" id="entryname" placeholder="Eintrag">
					<span class="input-group-btn">
						<button class="btn btn-success add-item" type="submit"><i class="fa fa-plus"></i></button>
					</span>
				</div>
			</form>
			<div class="entry-options folded">
				<button class="btn btn-default list-sort list-sort-name-asc active" type="button"><i class="fa fa-fw fa-sort-alpha-asc"></i></button>
				<button class="btn btn-default list-sort list-sort-name-desc" type="button"><i class="fa fa-fw fa-sort-alpha-desc"></i></button>
				<span class="small-space"></span>
				<button class="btn btn-default list-sort list-sort-date-asc" type="button"><i class="fa fa-fw fa-sort-numeric-asc"></i></button>
				<button class="btn btn-default list-sort list-sort-date-desc" type="button"><i class="fa fa-fw fa-sort-numeric-desc"></i></button>
				<span class="small-space"></span>
				<button class="btn btn-default list-sort list-hide-checked" type="button"><i class="fa fa-fw fa-sort-amount-asc"></i></button>
				<button class="btn btn-default list-sort list-sort-checked-at-end" type="button"><i class="fa fa-fw fa-sort-amount-desc"></i></button>
			</div>
		"""
		events :
			'click .toggle-entry-options' : () ->
				@$('.entry-options').toggleClass('folded')
				
			'click .list-sort-date-asc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-date-asc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:date:asc'
			'click .list-sort-date-desc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-date-desc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:date:desc'
				
			'click .list-sort-name-asc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-name-asc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:name:asc'
			'click .list-sort-name-desc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-name-desc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:name:desc'
				
			'click .list-sort-amount-asc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-amount-asc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:amount:asc'
			'click .list-sort-amount-desc' : () ->
				@$('button.list-sort').removeClass('active')
				@$('button.list-sort-amount-desc').addClass('active')
				App.vent.trigger 'todolist:lists:sort:amount:desc'
	
	App.TodoListApp.classes = {} if not App.TodoListApp.classes?
	App.TodoListApp.classes.EntryInputView = EntryInputView

	EntryInput.run = ->
		EntryInput.mainView = new App.TodoListApp.classes.EntryInputView()
		App.TodoListApp.mainView.entryInput.show(EntryInput.mainView);
	
	# EntryInput.on 'all', (a)->
	# 	console.log 'EntryInput events' + a
	
	EntryInput.addInitializer () -> 
#		EntryInput.run
	