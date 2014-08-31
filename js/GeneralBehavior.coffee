App.module 'GeneralBehavior', (GeneralBehavior, App, Backbone, Marionette, $, _) ->
	
	GeneralBehavior.on 'all', (a)->
		console.log 'GeneralBehavior events' + a
	
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
			"change @ui.itemName" : "inputChanged"
			
		inputChanged : (e) ->
			@view.ui.itemName.val()
			return true
			
		addItem : (e) ->
			console.debug 'addItem'
			view = _.result(@view, 'managedCollection')
			view.add  name : @view.ui.itemName.val() if view?
			return false
			
		# onRender : ->
		#

	Marionette.Behaviors.behaviorsLookup().AddSimpleItem = AddSimpleItem
	
	class Tooltip extends Marionette.Behavior
		onRender : ->
			@view.$('*[data-toggle="tooltip"]').tooltip()
			return true
	
	Marionette.Behaviors.behaviorsLookup().Tooltip = Tooltip