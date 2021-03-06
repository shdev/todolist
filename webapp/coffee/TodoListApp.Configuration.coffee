    App.module 'TodoListApp.Configuration', (Configuration, App, Backbone, Marionette, $, _) ->

        class TodoConfigurationModel extends Backbone.Model
            defaults : 
                continuousreplication : false # 
                username : "Brandt"
                replicateurl : null
                replicationinterval : 5 * 60
                deleteCheckedEntries : 5 * 24 *  60 * 60 
                deleteUnusedEntries : 24 *  60 * 60
                fetchingListData : false
                fetchingEntryData : false
                
                listStyle : "list"
                listSort : "nameAsc"
                
                entryStyle : "list"
                entrySort : "nameAsc"
                entryShowChecked : true
                
                unsyncedListChanges : 0
                unsyncedEntryChanges : 0
            
            blacklistAtrributes : []
            toJSON : (options) ->
                _.omit(this.attributes, this.blacklist)
            toggleEntryStyle : () -> 
                if 'list' == @get('entryStyle')
                    @set('entryStyle', 'inline')
                else
                    @set('entryStyle', 'list')
                @save()
            toggleEntryShowChecked : () -> 
                if @get('entryShowChecked')
                    @set('entryShowChecked', false)
                else
                    @set('entryShowChecked', true)
                @save()
            toggleListStyle : () -> 
                if 'list' == @get('listStyle')
                    @set('listStyle', 'inline')
                else
                    @set('listStyle', 'list')
                @save()
            incListChanges : () ->
                @set('unsyncedListChanges', parseInt(@get('unsyncedListChanges ')) + 1)
                @save()
            resetListChanges : () ->
                @set('unsyncedListChanges', 0)
                @save()
            incEntryChanges : () ->
                @set('unsyncedEntryChanges', parseInt(@get('unsyncedEntryChanges ')) + 1)
                @save()
            resetEntryChanges : () ->
                @set('unsyncedEntryChanges', 0)
                @save()
            validate : (attributes, options) ->
                returnValue = []            
                if not attributes.username? or not _.isString(attributes.username) or attributes.username.trim().length == 0
                    returnValue.push  'username'
                urlRegEx = /^(https?:\/\/)(?:\S+(?::\S*)?@)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/i
                if not attributes.replicateurl? or not _.isString(attributes.replicateurl) or attributes.replicateurl.trim().length == 0
                
                else 
                    if not urlRegEx.test(attributes.replicateurl)
                        returnValue.push 'replicateurl'
                    
                if returnValue.length == 0
                    undefined
                else
                    returnValue
            initialize : () -> 
                @listenTo App.vent, 'replication:pouchdb:to:complete', () ->
                    console.debug 'replication:pouchdb:to:complete'
                    @resetEntryChanges()
                    @resetListChanges()
                @listenTo App.vent, 'replication:pouchdb:to:uptodate', () ->
                    console.debug 'replication:pouchdb:to:uptodate'
                    @resetEntryChanges()
                    @resetListChanges()
            
        class TodoConfigurationCollection extends Backbone.Collection
            localStorage: new Backbone.LocalStorage("TodoListApp")
            model : TodoConfigurationModel

        Configuration.todoConfiguration = {}

        App.TodoListApp.classes = {} if not App.TodoListApp.classes?
        App.TodoListApp.classes.TodoConfigurationCollection = TodoConfigurationCollection
        App.TodoListApp.classes.TodoConfigurationModel = TodoConfigurationModel

        class ConfigurationView extends Marionette.LayoutView
            tagName : "form"
            setValues : () ->
                @$('input.username').val(@model.get('username'))
                @$('input.replicateurl').val(@model.get('replicateurl'))
                @$('input.continuousreplication').prop('checked', @model.get('continuousreplication'))
                @$('input.replicationinterval').val(@model.get('replicationinterval'))
                @$('input.delete-checked-entries').val(@model.get('deleteCheckedEntries'))
                @$('input.delete-unused-entries').val(@model.get('deleteUnusedEntries'))

                if (@model.isValid())
                    @$('.form-group').removeClass('has-error')
            saveEntries : () -> 
                    @model.save({username : @$('input.username').val().trim()})
                    @model.save({replicateurl: @$('input.replicateurl').val().trim()})
                    @model.save({replicationinterval: parseInt(@$('input.replicationinterval').val().trim())})
                    @model.save({continuousreplication: @$('input.continuousreplication').prop('checked')})
                    @model.save({deleteCheckedEntries: parseInt(@$('input.delete-checked-entries').val().trim())})
                    @model.save({deleteUnusedEntries: parseInt(@$('input.delete-unused-entries').val().trim())})
            events :
                'submit' : () ->
                    @saveEntries()
                    false

                'reset' : () ->
                    @setValues()
                    false

                'click .destroy-db' : () ->

                    swalOptions = 
                        title: "Bist Du Dir sicher?"
                        text: "Soll die Datenbank gelöscht werden."
                        type: "warning"
                        showCancelButton: true
                        confirmButtonClass: "btn-danger"
                        confirmButtonText: "Hau wech!"
                        cancelButtonText: "Ne,ne lass mal."
                        closeOnConfirm: false,
                        closeOnCancel: true

                    swalAction = (isConfirm) ->
                        if isConfirm
                            App.request("todolistapp:PouchDB").destroy()
                            App.vent.trigger('todolistapp:pouchdb:destroyed')
                            swal("Gelöscht!", "Alle Daten sind wech.", "success") 
                    
                    swal swalOptions, swalAction
                    false

                'click .cleanup-db' : () ->
                    App.request("todolistapp:PouchDB").compact()

            modelEvents : 
                'change' : () ->
                    @setValues()
                'invalid' : () ->
                    for field in @model.validationError
                        @$('.form-group.' + field).addClass('has-error')
                    
            template : _.template """
                <div class="username form-group has-error">
                    <label class="control-label" for="username">Benutzername</label>
                    <input type="text" class="form-control username" placeholder="Mein Name ist??" required />
                </div>
                <hr />
                <div class="replicateurl form-group has-error">
                    <label class="control-label" for="replicateurl">Adresse zum Replizieren</label>
                    <input type="url" class="form-control replicateurl" placeholder="http://" required />
                </div>
                <div class="continuousreplication form-group has-error">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" class="continuousreplication"><strong>Durchgängige Replikation</strong>
                        </label>
                    </div>
                </div>
                <div class="form-group replicationinterval has-error">
                    <label class="control-label" for="replicationinterval">Replikations- / Wiederversuchsinterval</label>
                    <div class="input-group">
                        <input class="form-control replicationinterval" required type="number" min="0" step="3" placeholder="0" />
                        <div class="input-group-btn">
                            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
                            <ul class="dropdown-menu dropdown-menu-right" role="menu">
                                <li><a href="#" class="sek">sek</a></li>
                                <li><a href="#" class="min">min</a></li>
                                <li><a href="#" class="h">h</a></li>
                            </ul>
                        </div><!-- /btn-group -->
                    </div>
                </div>
                <hr class=" hidden" />
                <div class="form-group delete-checked-entries has-error hidden">
                    <label class="control-label" for="delete-checked-entries">Löschen von abgearbeiteten Einträgen nach</label>
                    <div class="input-group">
                        <input type="number" class="form-control delete-checked-entries" min="0" step="3" placeholder="0" />
                        <div class="input-group-btn">
                            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
                            <ul class="dropdown-menu dropdown-menu-right" role="menu">
                                <li><a href="#" class="sek">sek</a></li>
                                <li><a href="#" class="min">min</a></li>
                                <li><a href="#" class="h">h</a></li>
                            </ul>
                        </div><!-- /btn-group -->
                    </div><!-- /input-group -->
                </div><!-- /form-group -->
                <div class="form-group delete-unused-entries has-error hidden">
                    <label class="control-label" for="delete-unused-entries">Löschen von ungenutzen Einträgen nach</label>
                    <div class="input-group">
                        <input type="number" class="form-control delete-unused-entries" min="0" step="3" placeholder="0" />
                        <div class="input-group-btn">
                            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="button-caption">sek</span> <span class="caret"></span></button>
                            <ul class="dropdown-menu dropdown-menu-right" role="menu">
                                <li><a href="#" class="sek">sek</a></li>
                                <li><a href="#" class="min">min</a></li>
                                <li><a href="#" class="h">h</a></li>
                            </ul>
                        </div><!-- /btn-group -->
                    </div><!-- /input-group -->
                </div><!-- /form-group -->

                <hr />
                <div class="row">
                    <div class="col-xs-6">
                        <button type="reset" class="btn-block btn btn-warning ">Zurücksetzen</button>
                    </div>
                    <div class="col-xs-6">
                        <button type="submit" class="btn-block btn btn-primary ">Speichern</button>
                    </div>
                </div>
                <hr />
                <hr />
                <div class="row form-group">
                    <div class="col-xs-12">
                        <label class="control-label ">Datenbank</label>
                    </div>
                    <div class="col-xs-6">
                        <button class="btn-block btn btn-danger destroy-db">Datenbank löschen</button>
                    </div>
                    <div class="col-xs-6">
                        <button class="btn-block btn btn-primary cleanup-db">Aufräumen</button>
                    </div>
                </div>
                <hr />
                <div class="row">
                    <div class="col-xs-12">

                        <div class="control-label">Library versions</div>

                        <dl class="dl-horizontal">
                            <dt>PouchDB</dt>
                            <dd><%= PouchDB.version %></dd>
                            <dt>jQuery</dt>
                            <dd><%= $().jquery %></dd>
                            <dt>Underscore</dt>
                            <dd><%= _.VERSION %></dd>
                            <dt>Backbone</dt>
                            <dd><%= Backbone.VERSION %></dd>
                            <dt>Marionette</dt>
                            <dd><%= Marionette.VERSION %></dd>
                            <dt>NumeralJS</dt>
                            <dd><%= numeral.version %></dd>
                            <dt>MomentJS</dt>
                            <dd><%= moment.version %></dd>
                        </dl>
                    </div>
                </div>
            
            """
            onRender : () ->
                @setValues()
                            
        configurationLoaded = ->
            App.vent.trigger 'todolist:configurationloaded', Configuration.todoConfiguration
            
        configurationErrorOnLoad = ->
            App.vent.trigger 'todolist:configurationerroronload'


        Configuration.run = ->
            Configuration.todoConfiguration = new TodoConfigurationCollection()
            App.reqres.setHandler "todolistapp:Configuration", () ->
                if Configuration.todoConfiguration.length == 0
                    Configuration.todoConfiguration.add(new TodoConfigurationModel())
                    Configuration.todoConfiguration.at(0).save(null, wait: true)
                    Configuration.todoConfiguration.at(0).on 'change', ->
                        Configuration.todoConfiguration.at(0).save()
                Configuration.todoConfiguration.at(0)

            Configuration.todoConfiguration.fetch(wait: true).done(configurationLoaded).fail(configurationErrorOnLoad) 
        
        App.mainRegion.on 'before:show', (view) -> 
            ###
            TODO check with instanceof
            ###
            Configuration.mainView = new ConfigurationView({model : Configuration.todoConfiguration.at(0)})
            view.configurationView.show(Configuration.mainView)
    

        Configuration.addInitializer () -> 
            Configuration.run()
    