App.module 'GeneralBehavior', (GeneralBehavior, App, Backbone, Marionette, $, _) ->
	
	# GeneralBehavior.on 'all', (a)->
	#
	
	###
		The following ui elements are required:
			addItemButton : click events, should be 
			itemName : a val() method
		
		The following methods/properties are required:
			managedCollection : either a collection or a function which returns a collection
	
		TODO: add some smarter handling to prevent empty names
	###
	
	class AddSimpleItem extends Marionette.Behavior
		events : 
			"click @ui.addItemButton" : "addItem"
			"keydown @ui.itemName" : "checkButtonState"
			
		checkButtonState : () ->
			if @view.ui.itemName.val().trim().length == 0 
				@view.ui.addItemButton.prop('disabled', true)
			else 
				@view.ui.addItemButton.prop('disabled', false)
			true
			
		addItem : (e) ->
			collection = _.result(@view, 'managedCollection')
			modelClass = _.result(@view, 'modelClass')
			if modelClass?
				model = new modelClass
					name : @view.ui.itemName.val()
				model.save()
				collection.add model if collection?
				@view.ui.itemName.val(null)
				@checkButtonState()
			return false
		onRender : () ->
			@checkButtonState()

	Marionette.Behaviors.behaviorsLookup().AddSimpleItem = AddSimpleItem
	
	class Tooltip extends Marionette.Behavior
		onRender : ->
			@view.$('*[data-toggle="tooltip"]').tooltip()
			true
	
	Marionette.Behaviors.behaviorsLookup().Tooltip = Tooltip