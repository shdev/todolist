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
				<form>
				<label class="control-label" for="listname">Liste anlegen</label>
				<div class="input-group">
					<span class="input-group-btn">
						<button class="btn btn-default toggle-list-options" type="button"><i class="fa fa-tasks"></i></button>
					</span>
					<input type="text" class="form-control" id="listname" placeholder="Liste">
					<span class="input-group-btn">
						<button class="btn btn-success add-item" type="submit"><i class="fa fa-plus"></i></button>
					</span>
				</div>
				</form>
				<div class="sort-options folded">
					<button class="btn btn-default list-sort list-sort-name-asc active" type="button"><i class="fa fa-fw fa-sort-alpha-asc"></i></button>
					<button class="btn btn-default list-sort list-sort-name-desc" type="button"><i class="fa fa-fw fa-sort-alpha-desc"></i></button>
					<span class="small-space"></span>
					<button class="btn btn-default list-sort list-sort-date-asc" type="button"><i class="fa fa-fw fa-sort-numeric-asc"></i></button>
					<button class="btn btn-default list-sort list-sort-date-desc" type="button"><i class="fa fa-fw fa-sort-numeric-desc"></i></button>
					<span class="small-space"></span>
					<button class="btn btn-default list-sort list-sort-amount-asc hidden" type="button"><i class="fa fa-fw fa-sort-amount-asc"></i></button>
					<button class="btn btn-default list-sort list-sort-amount-desc hidden" type="button"><i class="fa fa-fw fa-sort-amount-desc"></i></button>
				</div>
			"""
			events :
				'click .toggle-list-options' : () ->
					@$('.sort-options').toggleClass('folded')
				
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
