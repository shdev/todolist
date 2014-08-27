App.module 'EFBApp', (EFBApp, App, Backbone, Marionette, $, _) ->

	class EMailItemView extends Marionette.ItemView
		tagName : "li"
		className : "list-group-item"
		template : _.template """
		<%= eMail %> 
		<span class="delete badge hidden" data-toggle="tooltip" data-placement="top" title="Lösche Adresse"><i class="fa fa-trash-o fa-fw"></i></span>
		<span class="progressing badge bg-success hidden" data-toggle="tooltip" data-placement="top" title="Mail wird versendet"><i class="fa fa-spin fa-refresh fa-fw"></i></span>
		<span class="welldone badge bg-success hidden" data-toggle="tooltip" data-placement="top" title="Email wurde versendet"><i class="fa fa-paper-plane-o fa-fw"></i></span>
		<span class="error badge bg-success hidden" data-toggle="tooltip" data-placement="top" title="Fehler beim Versenden"><i class="fa fa-bolt fa-fw"></i></span>
		"""
		initialize : ->
			@model.correspondingView = @
		events :
			'click .delete' : () ->
				@model.destroy()
		# onBeforeRender :  ->
		# 	console.debug @model.get('eMail')
		state : 'delete'
		stateToDelete : ->
			@state = 'delete'
			@$el.find('span').addClass 'hidden'
			@$el.find('span.delete').removeClass('hidden')
		stateToProgressing : ->
			@state = 'progressing'
			@$el.find('span').addClass 'hidden'
			@$el.find('span.progressing').removeClass('hidden')
		stateToWelldone : ->
			@state = 'welldone'
			@$el.find('span').addClass 'hidden'
			@$el.find('span.welldone').removeClass('hidden')
		stateToError : ->
			@state = 'error'
			@$el.find('span').addClass 'hidden'
			@$el.find('span.error').removeClass('hidden')
		onRender : ->
			@$el.find('span').tooltip()
			switch @state
				when 'delete'
					@$el.find('span.error').removeClass('hidden')
					@$el.find('span.delete').removeClass('hidden')
				when 'progressing'
					@$el.find('span.progressing').removeClass('hidden')
				when 'welldone'
					@$el.find('span.welldone').removeClass('hidden')
					@$el.find('span.delete').removeClass('hidden')
				when 'error'
					@$el.find('span.error').removeClass('hidden')
					@$el.find('span.delete').removeClass('hidden')
				
		
	class EMailCollectionView extends Marionette.CollectionView
		tagName : "ul"
		className : "list-group"
		childView : EMailItemView

	# class EMailModel extends Backbone.Model
	# 	url :

	class EMailCollection extends Backbone.Collection
		model : Backbone.Model
		url : 'api/processMessage'

	class MainView extends Marionette.LayoutView
		className : "container"
		eMailList : new EMailCollection()
		template : _.template """
		<!-- <form role="form"> -->
			<div class="form-group">
				<label for="emaillist">Email Adressen</label>
				<textarea class="emaillist form-control" rows="10"></textarea>
			</div>
			<div class="span6 pager">
				<button class="convert btn btn-success">Addressen übernehmen</button>
			</div>
			<div id="emailadresschecklist">
			</div>
			
			<hr />
			
			<div class="form-group">
				<label for="subjectformail">Betreff der Mail</label>
				<input class="subjectformail form-control" rows="15" />
			</div>
			<div class="form-group">
				<label for="contentformail">Inhalt der Mail</label>
				<textarea class="contentformail form-control" rows="15"></textarea>
			</div>
			<div class="span6 pager">
				<button class="send btn btn-success">Versenden</button>
			</div>
		<!-- </form> -->
		"""
		events : 
			"click .btn.convert" : (e) ->
				elem = @$el.find('.emaillist')
				t = elem.val()
				t = t.replace('\r\n', '\n')
				eMailValidator = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/
				validEmails = 0
				# @eMailList.reset()
				rejected = []
				for oneline in _.chain(t.split('\n')).map((s) -> return s.trim()).uniq().value()
					oneline = oneline.trim()
					if oneline.length > 0
						if eMailValidator.test(oneline)
							# TODO check whether the eMailAdress is there
							@eMailList.add([{eMail : oneline}])
						else
							rejected.push oneline
				elem.val(rejected.join '\n')
			"click .btn.send" : (e) ->
				@eMailList.each (model) ->
					if model.correspondingView.state == 'delete' or model.correspondingView.state == 'error'
						model.set('message', @$('textarea.contentformail').val())
						model.set('subject', @$('input.subjectformail').val())
						model.correspondingView.stateToProgressing()
						model.save()
						     .done( () -> model.correspondingView.stateToWelldone())
							 .fail( () -> model.correspondingView.stateToError())
					
		regions : 
			list : "#emailadresschecklist"

	EFBApp = 
		run : -> 
			@mainView = new MainView()
			window.mainView = @mainView
			
			window.eMailList = @mainView.eMailList
			console.debug App
			App.mainRegion.show(@mainView);
			
			@mainView.list.show new EMailCollectionView({ collection : @mainView.eMailList })
						
			App.vent.trigger('app:initialized', App)
			
	App.addInitializer ->
		EFBApp.run()




###

mail@sh-dev.de
me@violaholtz.de


###