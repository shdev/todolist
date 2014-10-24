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
					@$('.toggle-entry-options').toggleClass('active')
				
				'click .entry-sort-date-asc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('entrySort', 'dateAsc')
						 config.save()
				'click .entry-sort-date-desc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('entrySort', 'dateDesc')
						 config.save()
				
				'click .entry-sort-name-asc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('entrySort', 'nameAsc')
						 config.save()
				'click .entry-sort-name-desc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('entrySort', 'nameDesc')
						 config.save()
						 
				'click .toggle-style' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.toggleEntryStyle()
				'click .toggle-show-checked' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.toggleEntryShowChecked()
			changeStyle : (model,value) ->
				if 'inline' == value
					@$('.toggle-style').removeClass('active')
				else
					@$('.toggle-style').addClass('active')
			changeSort : (model,sortType) ->
				@$('button.entry-sort').removeClass('active')
				switch sortType 
					when "nameAsc"
						@$('button.entry-sort-name-asc').addClass('active')
					when "nameDesc"
						@$('button.entry-sort-name-desc').addClass('active')
					when "dateAsc"
						@$('button.entry-sort-date-asc').addClass('active')
					when "dateDesc"
						@$('button.entry-sort-date-desc').addClass('active')
			toggleShowChecked : (model,value) ->
				if value
					@$('.toggle-show-checked').addClass('active')
				else
					@$('.toggle-show-checked').removeClass('active')
			onRender : () ->
				config = App.request("todolistapp:Configuration")
				@changeStyle config, config.get('entryStyle')
				@changeSort config, config.get('entrySort')
				@toggleShowChecked config, config.get('entryShowChecked')
			initialize : () ->
				config = App.request("todolistapp:Configuration")
				if config?
					@listenTo config, "change:entryStyle", @changeStyle
					@listenTo config, "change:entryShowChecked", @toggleShowChecked
					@listenTo config, "change:entrySort", @changeSort
	
		App.TodoListApp.classes = {} if not App.TodoListApp.classes?
		App.TodoListApp.classes.EntryInputView = EntryInputView

		EntryInput.run = ->
			EntryInput.mainView = new App.TodoListApp.classes.EntryInputView()
			App.TodoListApp.mainView.entryInput.show(EntryInput.mainView);
	
		# EntryInput.on 'all', (a)->
		# 	console.log 'EntryInput events' + a
	
		EntryInput.addInitializer () -> 
	#		EntryInput.run
	