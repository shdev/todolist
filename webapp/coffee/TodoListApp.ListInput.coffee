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
					<span class="small-space hidden"></span>
					<button class="btn btn-default list-sort list-sort-amount-asc hidden" type="button"><i class="fa fa-fw fa-sort-amount-asc"></i></button>
					<button class="btn btn-default list-sort list-sort-amount-desc hidden" type="button"><i class="fa fa-fw fa-sort-amount-desc"></i></button>
						
					<span class="small-space"></span>
					<button class="btn btn-default toggle-style" type="button"><i class="fa fa-th-list"></i></button>
					
				</div>
			"""
			events :
				'click .toggle-list-options' : () ->
					@$('.sort-options').toggleClass('folded')
					@$('.toggle-list-options').toggleClass('active')
					
				'click .toggle-style' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.toggleListStyle()
						 
				'click .list-sort-date-asc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'dateAsc')
						 config.save()
				'click .list-sort-date-desc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'dateDesc')
						 config.save()
						 
				'click .list-sort-name-asc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'nameAsc')
						 config.save()
				'click .list-sort-name-desc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'nameDesc')
						 config.save()
				
				'click .list-sort-amount-asc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'amountAsc')
						 config.save()
				'click .list-sort-amount-desc' : () ->
					config = App.request("todolistapp:Configuration")
					if config?
						 config.set('listSort', 'amountDesc')
						 config.save()
			changeStyle : (model,value) ->
				if 'inline' == value
					@$('.toggle-style').removeClass('active')
				else
					@$('.toggle-style').addClass('active')
			changeSort : (model,sortType) ->
				console.debug sortType
				
				@$('button.list-sort').removeClass('active')
				switch sortType 
					when "nameAsc"
						@$('button.list-sort-name-asc').addClass('active')
					when "nameDesc"
						@$('button.list-sort-name-desc').addClass('active')
					when "dateAsc"
						@$('button.list-sort-date-asc').addClass('active')
					when "dateDesc"
						@$('button.list-sort-date-desc').addClass('active')
					when "amountAsc"
						@$('button.list-sort-amount-asc').addClass('active')
					when "amountDesc"
						@$('button.list-sort-amount-desc').addClass('active')
			onRender : () ->
				config = App.request("todolistapp:Configuration")
				@changeStyle(config, config.get('listStyle'))
				@changeSort(config, config.get('listSort'))
			initialize : () ->
				config = App.request("todolistapp:Configuration")
				if config?
					@listenTo config, "change:listStyle", @changeStyle
					@listenTo config, "change:listSort", @changeSort
			
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
