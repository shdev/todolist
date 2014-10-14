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
					<button class="btn btn-default entry-sort entry-sort-name-asc active" type="button"><i class="fa fa-fw fa-sort-alpha-asc"></i></button>
					<button class="btn btn-default entry-sort entry-sort-name-desc" type="button"><i class="fa fa-fw fa-sort-alpha-desc"></i></button>
					<span class="small-space"></span>
					<button class="btn btn-default entry-sort entry-sort-date-asc" type="button"><i class="fa fa-fw fa-sort-numeric-asc"></i></button>
					<button class="btn btn-default entry-sort entry-sort-date-desc" type="button"><i class="fa fa-fw fa-sort-numeric-desc"></i></button>
					<span class="small-space"></span>
					<button class="btn btn-default toggle-show-checked" type="button"><i class="fa fa-fw fa-check-square-o"></i></button>
					<span class="small-space"></span>
					<button class="btn btn-default toggle-style" type="button"><i class="fa fa-th-list"></i></button>
				</div>
			"""
			events :
				'click .toggle-entry-options' : () ->
					@$('.entry-options').toggleClass('folded')
				
				'click .entry-sort-date-asc' : () ->
					@$('button.entry-sort').removeClass('active')
					@$('button.entry-sort-date-asc').addClass('active')
					App.vent.trigger 'todolist:entries:sort:date:asc'
				'click .entry-sort-date-desc' : () ->
					@$('button.entry-sort').removeClass('active')
					@$('button.entry-sort-date-desc').addClass('active')
					App.vent.trigger 'todolist:entries:sort:date:desc'
				
				'click .entry-sort-name-asc' : () ->
					@$('button.entry-sort').removeClass('active')
					@$('button.entry-sort-name-asc').addClass('active')
					App.vent.trigger 'todolist:entries:sort:name:asc'
				'click .entry-sort-name-desc' : () ->
					@$('button.entry-sort').removeClass('active')
					@$('button.entry-sort-name-desc').addClass('active')
					App.vent.trigger 'todolist:entries:sort:name:desc'
					
				'click .toggle-style' : () ->
					@$('.toggle-style').toggleClass('active')
					App.vent.trigger 'todolist:entries:toggle:style'
					
				'click .toggle-show-checked' : () ->
					@$('.toggle-show-checked').toggleClass('active')
					App.vent.trigger 'todolist:entries:toggle:show:checked'
	
		App.TodoListApp.classes = {} if not App.TodoListApp.classes?
		App.TodoListApp.classes.EntryInputView = EntryInputView

		EntryInput.run = ->
			EntryInput.mainView = new App.TodoListApp.classes.EntryInputView()
			App.TodoListApp.mainView.entryInput.show(EntryInput.mainView);
	
		# EntryInput.on 'all', (a)->
		# 	console.log 'EntryInput events' + a
	
		EntryInput.addInitializer () -> 
	#		EntryInput.run
	