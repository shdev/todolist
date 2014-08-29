App.module 'GeneralBehavior', (GeneralBehavior, App, Backbone, Marionette, $, _) ->

	window.Behaviors = {} if not window.Behaviors?
		
	Marionette.Behaviors.behaviorsLookup = ->
		return window.Behaviors

	class AddSimpleItem extends Marionette.Behavior
		events : 
			"click @ui.addItemButton" : "addItem"
			"change @ui.itemName" : "inputChanged"
			
		inputChanged : (e) ->
			console.debug 'd.fm'
			return true
			
		addItem : (e) ->
			console.debug @
			console.debug 'sdvknsdlvn'
			@view.getCollection().add  name : @view.ui.itemName.val()
			return true

	window.Behaviors.AddSimpleItem = AddSimpleItem