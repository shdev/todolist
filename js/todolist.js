// Generated by CoffeeScript 1.7.1

/* https://gist.github.com/alecperkins/3363111 */
var App, TodoListApplication, init,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TodoListApplication = (function(_super) {
  __extends(TodoListApplication, _super);

  function TodoListApplication() {
    return TodoListApplication.__super__.constructor.apply(this, arguments);
  }

  return TodoListApplication;

})(Marionette.Application);

App = new TodoListApplication();

App.on('all', function(a, b, c, d, e) {
  return console.log('App events' + a);
});

App.addRegions({
  mainRegion: 'body'
});

if (window.Behaviors == null) {
  window.Behaviors = {};
}

Marionette.Behaviors.behaviorsLookup = function() {
  return window.Behaviors;
};

init = function() {
  return App.start();
};

$(init);

App.module('GeneralBehavior', function(GeneralBehavior, App, Backbone, Marionette, $, _) {
  var AddSimpleItem, Tooltip;
  GeneralBehavior.on('all', function(a) {
    return console.log('GeneralBehavior events' + a);
  });

  /*
  		The following ui elements are required:
  			addItemButton : click events, should be 
  			itemName : a val() method
  		
  		The following methods/properties are required:
  			managedCollection : either a collection or a function which returns a collection
  	
  		TODO: add some smarter handling to prevent empty names
   */
  AddSimpleItem = (function(_super) {
    __extends(AddSimpleItem, _super);

    function AddSimpleItem() {
      return AddSimpleItem.__super__.constructor.apply(this, arguments);
    }

    AddSimpleItem.prototype.events = {
      "click @ui.addItemButton": "addItem",
      "change @ui.itemName": "inputChanged"
    };

    AddSimpleItem.prototype.inputChanged = function(e) {
      this.view.ui.itemName.val();
      return true;
    };

    AddSimpleItem.prototype.addItem = function(e) {
      var collection, model, modelClass;
      console.debug('addItem');
      collection = _.result(this.view, 'managedCollection');
      modelClass = _.result(this.view, 'modelClass');
      if (modelClass != null) {
        model = new modelClass({
          name: this.view.ui.itemName.val()
        });
        console.debug('save new item');
        model.save();
        console.debug(model.toJSON());
        if (collection != null) {
          collection.add(model);
        }
      }
      return false;
    };

    return AddSimpleItem;

  })(Marionette.Behavior);
  Marionette.Behaviors.behaviorsLookup().AddSimpleItem = AddSimpleItem;
  Tooltip = (function(_super) {
    __extends(Tooltip, _super);

    function Tooltip() {
      return Tooltip.__super__.constructor.apply(this, arguments);
    }

    Tooltip.prototype.onRender = function() {
      this.view.$('*[data-toggle="tooltip"]').tooltip();
      return true;
    };

    return Tooltip;

  })(Marionette.Behavior);
  return Marionette.Behaviors.behaviorsLookup().Tooltip = Tooltip;
});

App.module('TodoListApp', function(TodoListApp, App, Backbone, Marionette, $, _) {

  /*
  	TODO requestHandling for the classes
   */
  var TodoListAppView, doReplicationFrom, doReplicationTo, pouchDB, pouchdbRepFrom, pouchdbRepTo, timeOutRepFrom, timeOutRepTo;
  TodoListAppView = (function(_super) {
    __extends(TodoListAppView, _super);

    function TodoListAppView() {
      return TodoListAppView.__super__.constructor.apply(this, arguments);
    }

    TodoListAppView.prototype.className = "container";

    TodoListAppView.prototype.template = _.template("\n<div id=\"todolistapp-lists\">\n	<div id=\"todolistapp-list-input\"></div>\n	<hr />\n	<div id=\"todolistapp-lists-view\"></div>\n</div>\n<hr />\n<hr />\n<div id=\"todolistapp-entries\">\n	<div id=\"todolistapp-entry-input\"></div>\n	<hr />\n	<div id=\"todolistapp-entries-view\"></div>\n</div>\n<hr />\n<hr />\n<div id=\"todolistapp-configuration\"></div>");

    TodoListAppView.prototype.regions = {
      listsArea: "#todolistapp-lists",
      listInput: "#todolistapp-list-input",
      listsView: "#todolistapp-lists-view",
      entriesArea: "#todolistapp-entries",
      entryInput: "#todolistapp-entry-input",
      entriesView: "#todolistapp-entries-view",
      configurationView: "#todolistapp-configuration"
    };

    return TodoListAppView;

  })(Marionette.LayoutView);
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.TodoListAppView;
  pouchDB = void 0;
  App.reqres.setHandler("TodoListApp:PouchDB", function() {
    if (typeof pouch === "undefined" || pouch === null) {
      pouchDB = new PouchDB('svh_todo', {
        adapter: 'websql'
      });
    }
    return pouchDB;
  });
  App.vent.on('todolist:configurationloaded', function(config) {
    console.debug('todolist:configurationloaded');
    App.request("TodoListApp:PouchDB");
    App.vent.trigger('todolistapp:startReplication');
    return App.vent.trigger('todolistapp:initViews');
  });
  App.vent.on('todolistapp:initViews', function() {
    console.debug('todolistapp:initViews');
    TodoListApp.mainView = new TodoListAppView();
    console.debug(TodoListApp.mainView);
    window.TodoListApp = TodoListApp;
    return App.mainRegion.show(TodoListApp.mainView);
  });
  pouchdbRepTo = void 0;
  pouchdbRepFrom = void 0;
  timeOutRepTo = void 0;
  timeOutRepFrom = void 0;
  doReplicationTo = function() {
    var currentConfiguration, currentPouchDB;
    console.debug('doReplicationTo');
    currentPouchDB = App.request("TodoListApp:PouchDB");
    currentConfiguration = App.request("TodoListApp:Configuration");
    if (timeOutRepTo != null) {
      clearTimeout(timeOutRepTo);
      timeOutRepTo = void 0;
    }
    if (pouchdbRepTo != null) {
      pouchdbRepTo.cancel();
      App.vent.trigger('replication:pouchdb:to:cancel');
    }
    if ((pouchdbRepTo == null) && (currentConfiguration.get('replicateurl') != null)) {
      pouchdbRepTo = currentPouchDB.replicate.to(currentConfiguration.get('replicateurl'), {
        live: currentConfiguration.get('continuousreplication')
      });
      pouchdbRepTo.on('uptodate', function() {
        return App.vent.trigger('replication:pouchdb:to:uptodate');
      });
      pouchdbRepTo.on('error', function() {
        pouchdbRepTo.cancel();
        pouchdbRepTo = void 0;
        return App.vent.trigger('replication:pouchdb:to:error');
      });
      pouchdbRepTo.on('complete', function() {
        App.vent.trigger('replication:pouchdb:to:complete');
        if (App.TodoListApp.listCollection != null) {
          return App.TodoListApp.listCollection.fetch();
        }
      });
      if (!currentConfiguration.get('continuousreplication') && (currentConfiguration.get('replicationinterval') != null) && currentConfiguration.get('replicationinterval') > 0) {
        return setTimeout(doReplicationTo, currentConfiguration.get('replicationinterval'));
      }
    }
  };
  doReplicationFrom = function() {
    var currentConfiguration, currentPouchDB;
    console.debug('doReplicationFrom');
    currentPouchDB = App.request("TodoListApp:PouchDB");
    currentConfiguration = App.request("TodoListApp:Configuration");
    if (timeOutRepFrom != null) {
      clearTimeout(timeOutRepFrom);
      timeOutRepFrom = void 0;
    }
    if (pouchdbRepFrom != null) {
      pouchdbRepFrom.cancel();
      App.vent.trigger('replication:pouchdb:from:cancel');
    }
    if ((pouchdbRepFrom == null) && (currentConfiguration.get('replicateurl') != null)) {
      pouchdbRepFrom = currentPouchDB.replicate.from(currentConfiguration.get('replicateurl'), {
        live: currentConfiguration.get('continuousreplication')
      });
      pouchdbRepFrom.on('uptodate', function() {
        return App.vent.trigger('replication:pouchdb:from:uptodate');
      });
      pouchdbRepFrom.on('error', function() {
        pouchdbRepFrom.cancel();
        pouchdbRepFrom = void 0;
        return App.vent.trigger('replication:pouchdb:from:error');
      });
      return pouchdbRepFrom.on('complete', function() {
        App.vent.trigger('replication:pouchdb:from:complete');
        if (App.TodoListApp.listCollection != null) {
          return App.TodoListApp.listCollection.fetch();
        }
      });
    }
  };
  App.vent.on('todolistapp:startReplication', function() {
    doReplicationTo();
    return doReplicationFrom();
  });
  TodoListApp.run = function() {

    /*
    			TODO a better replication handling
     */
    window.TodoListApp;
    return App.vent.trigger('app:initialized', App);
  };
  App.vent.on('replication:svh_todo:uptodate', function() {
    if (App.TodoListApp.listCollection != null) {
      App.TodoListApp.listCollection.fetch();
    }
    if (App.TodoListApp.entryCollection != null) {
      return App.TodoListApp.entryCollection.fetch();
    }
  });
  return App.addInitializer(function() {
    console.debug('TodoListApp App.addInitializer');
    return TodoListApp.run();
  });
});

App.module('TodoListApp.EntryInput', function(EntryInput, App, Backbone, Marionette, $, _) {
  var EntryInputView;
  EntryInputView = (function(_super) {
    __extends(EntryInputView, _super);

    function EntryInputView() {
      return EntryInputView.__super__.constructor.apply(this, arguments);
    }

    EntryInputView.prototype.ui = {
      "addItemButton": "button.add-item",
      "itemName": "input"
    };

    EntryInputView.prototype.behaviors = {
      AddSimpleItem: {}
    };

    EntryInputView.prototype.managedCollection = function() {
      return App.TodoListApp.entryCollection;
    };

    EntryInputView.prototype.modelClass = function() {
      return App.TodoListApp.classes.EntryModel;
    };

    EntryInputView.prototype.className = "form-group";

    EntryInputView.prototype.template = _.template("<label for=\"entryname\">Eintrag eintragen</label>\n<form>\n	<div class=\"input-group\">\n		<input type=\"text\" class=\"form-control\" id=\"entryname\" placeholder=\"Eintrag\">\n		<span class=\"input-group-btn\">\n			<button class=\"btn btn-success add-item\" type=\"submit\"><i class=\"fa fa-plus\"></i></button>\n		</span>\n	</div>\n</form>");

    return EntryInputView;

  })(Marionette.LayoutView);
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.EntryInputView = EntryInputView;
  EntryInput.run = function() {
    console.debug('TodoListApp.EntryInput.run');
    EntryInput.mainView = new App.TodoListApp.classes.EntryInputView();
    return App.TodoListApp.mainView.entryInput.show(EntryInput.mainView);
  };
  EntryInput.on('all', function(a) {
    return console.log('EntryInput events' + a);
  });
  return EntryInput.addInitializer(function() {});
});

App.module('TodoListApp.ListInput', function(ListInput, App, Backbone, Marionette, $, _) {
  var ListInputView;
  ListInputView = (function(_super) {
    __extends(ListInputView, _super);

    function ListInputView() {
      return ListInputView.__super__.constructor.apply(this, arguments);
    }

    ListInputView.prototype.className = "form-group";

    ListInputView.prototype.ui = {
      "addItemButton": "button.add-item",
      "itemName": "input"
    };

    ListInputView.prototype.behaviors = {
      AddSimpleItem: {}
    };

    ListInputView.prototype.managedCollection = function() {
      return App.TodoListApp.listCollection;
    };

    ListInputView.prototype.modelClass = function() {
      return App.TodoListApp.classes.ListModel;
    };

    ListInputView.prototype.template = _.template("<label class=\"control-label\" for=\"listname\">Liste anlegen</label>\n<form>\n<div class=\"input-group\">\n	<input type=\"text\" class=\"form-control\" id=\"listname\" placeholder=\"Liste\">\n	<span class=\"input-group-btn\">\n		<button class=\"btn btn-success add-item\" type=\"submit\"><i class=\"fa fa-plus\"></i></button>\n	</span>\n</div>\n</form>");

    return ListInputView;

  })(Marionette.LayoutView);
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.ListInputView = ListInputView;
  ListInput.run = function() {
    console.debug('TodoListApp.ListInput.run');
    this.mainView = new ListInputView();
    return App.TodoListApp.mainView.listInput.show(this.mainView);
  };
  App.mainRegion.on('before:show', function(view) {
    console.debug("App.mainregion.on 'before:show'");
    console.debug(view);

    /*
    		TODO check with instanceof
     */
    ListInput.mainView = new ListInputView();
    return view.listInput.show(ListInput.mainView);
  });
  ListInput.on('all', function(a) {
    return console.log('ListInput events' + a);
  });
  return ListInput.addInitializer(function() {});
});

App.module('TodoListApp.ListsView', function(ListsView, App, Backbone, Marionette, $, _) {
  var ListCollection, ListCollectionView, ListItemView, ListModel, NoEntrieView, listCollection, pouchdbOptions;
  NoEntrieView = (function(_super) {
    __extends(NoEntrieView, _super);

    function NoEntrieView() {
      return NoEntrieView.__super__.constructor.apply(this, arguments);
    }

    NoEntrieView.prototype.tagName = "li";

    NoEntrieView.prototype.className = "list-group-item list-group-item-warning";

    NoEntrieView.prototype.template = _.template("Es gibt keine Einträge!");


    /*
    		TODO watch out for the collection loads data
     */

    NoEntrieView.prototype.onRender = function() {
      return console.debug('Render NoEntrieView');
    };

    return NoEntrieView;

  })(Marionette.ItemView);
  ListItemView = (function(_super) {
    __extends(ListItemView, _super);

    function ListItemView() {
      return ListItemView.__super__.constructor.apply(this, arguments);
    }

    ListItemView.prototype.tagName = "li";

    ListItemView.prototype.className = "list-group-item";

    ListItemView.prototype.cid = 'ListItemView';

    ListItemView.prototype.template = _.template("<span class=\"content\"><%= name %></span>\n<span class=\"badge delete\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Lösche Adresse\"><i class=\"fa fa-trash-o fa-fw\" ></i></span>");

    ListItemView.prototype.behaviors = {
      Tooltip: {}
    };

    ListItemView.prototype.initialize = function() {
      return this.model.correspondingView = this;
    };

    ListItemView.prototype.events = {
      'click .delete': function() {
        this.model.destroy();
        return false;
      },
      'click': function() {
        if (!this.$el.hasClass('list-group-item-success')) {
          this.$el.siblings().removeClass('list-group-item-success');
          return App.vent.trigger('todolist:changelist', this.model);
        }
      }
    };

    ListItemView.prototype.clicked = function() {
      return this.$el.addClass('list-group-item-success');
    };

    ListItemView.prototype.onRender = function() {
      var thisModel;
      console.debug('Render List: ' + this.model.get('name'));
      thisModel = this.model;
      this.$(".content").editable({
        type: 'text',
        name: 'Name eingeben',
        value: this.model.get('name'),
        pk: this.model.get('id'),
        url: '',
        mode: 'inline',
        success: function(response, newValue) {
          thisModel.set('name', newValue);
          return thisModel.save();
        }
      });
      return true;
    };

    return ListItemView;

  })(Marionette.ItemView);
  ListCollectionView = (function(_super) {
    __extends(ListCollectionView, _super);

    function ListCollectionView() {
      return ListCollectionView.__super__.constructor.apply(this, arguments);
    }

    ListCollectionView.prototype.tagName = "ul";

    ListCollectionView.prototype.className = "list-group";

    ListCollectionView.prototype.childView = ListItemView;

    ListCollectionView.prototype.emptyView = NoEntrieView;

    return ListCollectionView;

  })(Marionette.CollectionView);
  ListModel = (function(_super) {
    __extends(ListModel, _super);

    function ListModel() {
      return ListModel.__super__.constructor.apply(this, arguments);
    }

    ListModel.prototype.idAttribute = '_id';

    ListModel.prototype.defaults = {
      type: 'todolist',
      created: JSON.parse(JSON.stringify(new Date()))
    };

    ListModel.prototype.sync = BackbonePouch.sync({
      db: PouchDB('svh_todo', {
        adapter: 'websql'
      })
    });

    ListModel.prototype.initialize = function() {
      return this.on('destroy', function(a) {
        if ((a != null) && (a.id != null)) {
          return App.vent.trigger('todolist:deleted-list', a.id);
        }
      });
    };

    return ListModel;

  })(Backbone.Model);
  pouchdbOptions = {
    db: PouchDB('svh_todo', {
      adapter: 'websql'
    }),
    fetch: 'query',
    options: {
      query: {
        include_docs: true,
        fun: {
          map: function(doc) {
            if (doc.type === 'todolist') {
              return emit(doc.position, null);
            }
          }
        }
      }
    }
  };
  ListCollection = (function(_super) {
    __extends(ListCollection, _super);

    function ListCollection() {
      return ListCollection.__super__.constructor.apply(this, arguments);
    }

    ListCollection.prototype.model = ListModel;

    ListCollection.prototype.sync = BackbonePouch.sync(pouchdbOptions);

    ListCollection.prototype.comparator = 'created';

    ListCollection.prototype.parse = function(result) {
      console.debug('parse lists');
      console.debug(result);
      return _.pluck(result.rows, 'doc');
    };

    return ListCollection;

  })(Backbone.Collection);
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.ListItemView = ListItemView;
  App.TodoListApp.classes.ListCollectionView = ListCollectionView;
  App.TodoListApp.classes.ListCollection = ListCollection;
  App.TodoListApp.classes.ListModel = ListModel;
  ListsView.run = function() {
    console.debug('TodoListApp.ListsView');
    this.mainView = new ListCollectionView({
      collection: new ListCollection()
    });
    App.TodoListApp.mainView.listsView.show(this.mainView);
    App.TodoListApp.listCollection = this.mainView.collection;
    return this.mainView.collection.fetch();
  };
  ListsView.addInitializer(function() {});
  App.vent.on('todolist:changelist', function(todolistmodel) {
    console.debug('todolist:changelist ListsView');
    console.debug(todolistmodel.id);
    return todolistmodel.correspondingView.clicked();
  });

  /*
  	TODO request Handling
   */
  listCollection = void 0;
  App.mainRegion.on('before:show', function(view) {
    console.debug("App.mainregion.on 'before:show'");
    console.debug(view);

    /*
    		TODO check with instanceof
     */
    ListsView.mainView = new ListCollectionView({
      collection: new ListCollection()
    });
    view.listsView.show(ListsView.mainView);
    App.TodoListApp.listCollection = ListsView.mainView.collection;
    return ListsView.mainView.collection.fetch();
  });
  ListsView.on("start", function() {
    console.debug("ListView.onStart");
    return true;
  });
  return ListsView.on('all', function(a) {
    return console.log('ListsView events' + a);
  });
});

App.module('TodoListApp.EntriesView', function(EntriesView, App, Backbone, Marionette, $, _) {
  var EntryCollectionFactory, EntryCollectionView, EntryItemView, EntryModelFactory, NoEntrieView;
  NoEntrieView = (function(_super) {
    __extends(NoEntrieView, _super);

    function NoEntrieView() {
      return NoEntrieView.__super__.constructor.apply(this, arguments);
    }

    NoEntrieView.prototype.tagName = "li";

    NoEntrieView.prototype.className = "list-group-item list-group-item-warning";

    NoEntrieView.prototype.template = _.template("Es gibt keine Einträge!");


    /*
    		TODO watch out for the collection loads data
     */

    NoEntrieView.prototype.onRender = function() {
      return console.debug('Render NoEntrieView');
    };

    return NoEntrieView;

  })(Marionette.ItemView);
  EntryItemView = (function(_super) {
    __extends(EntryItemView, _super);

    function EntryItemView() {
      return EntryItemView.__super__.constructor.apply(this, arguments);
    }

    EntryItemView.prototype.tagName = "li";

    EntryItemView.prototype.className = "list-group-item todolist-entry";

    EntryItemView.prototype.template = _.template("<span class=\"fa-stack checkbox\">\n  <i class=\"fa fa-fw fa-square-o fa-stack-2x\"></i>\n  <i class=\"fa fa-fw fa-check fa-stack-1x checktoggle\"></i>\n</span>\n<span class=\"content\"><%= name %></span>\n<span class=\"delete badge\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Lösche Adresse\"><i class=\"fa fa-trash-o fa-fw\"></i></span>");

    EntryItemView.prototype.behaviors = {
      Tooltip: {}
    };

    EntryItemView.prototype.initialize = function() {
      return this.model.correspondingView = this;
    };

    EntryItemView.prototype.modelEvents = {
      "change:checked": 'renderCheckStatus',
      "change:name": 'reRenderName'
    };

    EntryItemView.prototype.events = {
      'click .delete': function() {
        this.model.destroy();
        return false;
      },
      'click': function() {
        this.$el.siblings().removeClass('list-group-item-success');
        return this.$el.addClass('list-group-item-success');
      },
      'click .checkbox': function() {
        this.model.toggleCheck();
        this.model.save();
        return false;
      }
    };

    EntryItemView.prototype.reRenderName = function() {
      return this.$('.content').text(this.model.get('name'));
    };

    EntryItemView.prototype.renderCheckStatus = function() {
      console.debug('CheckStatus');
      console.debug(this.model.get('checked'));
      if (this.model.get('checked') != null) {
        console.debug('checked');
        return this.$el.addClass('ischecked');
      } else {
        console.debug('unchecked');
        return this.$el.removeClass('ischecked');
      }
    };

    EntryItemView.prototype.onRender = function() {
      var thisModel;
      console.debug('Render Entry: ' + this.model.get('name'));
      console.debug(this.model);
      thisModel = this.model;
      this.$(".content").editable({
        type: 'text',
        name: 'Name eingeben',
        value: this.model.get('name'),
        pk: this.model.get('id'),
        url: '',
        mode: 'inline',
        success: function(response, newValue) {
          thisModel.set('name', newValue);
          return thisModel.save();
        }
      });
      this.renderCheckStatus();
      this.renderCheckStatus();
      return true;
    };

    return EntryItemView;

  })(Marionette.ItemView);
  EntryCollectionView = (function(_super) {
    __extends(EntryCollectionView, _super);

    function EntryCollectionView() {
      return EntryCollectionView.__super__.constructor.apply(this, arguments);
    }

    EntryCollectionView.prototype.tagName = "ul";

    EntryCollectionView.prototype.className = "list-group todolist-entries-list";

    EntryCollectionView.prototype.childView = EntryItemView;

    EntryCollectionView.prototype.emptyView = NoEntrieView;

    return EntryCollectionView;

  })(Marionette.CollectionView);
  EntryModelFactory = function(todolistid) {
    var EntryModel;
    EntryModel = (function(_super) {
      __extends(EntryModel, _super);

      function EntryModel() {
        return EntryModel.__super__.constructor.apply(this, arguments);
      }

      EntryModel.prototype.idAttribute = '_id';

      EntryModel.prototype.defaults = {
        type: 'todoentry',
        created: JSON.parse(JSON.stringify(new Date())),
        "todolist-id": todolistid,
        checked: null
      };

      EntryModel.prototype.sync = BackbonePouch.sync({
        db: PouchDB('svh_todo', {
          adapter: 'websql'
        })
      });

      EntryModel.prototype.check = function() {
        if (this.get('checked') == null) {
          return this.set('checked', JSON.parse(JSON.stringify(new Date())));
        }
      };

      EntryModel.prototype.unCheck = function() {
        if (this.get('checked') != null) {
          return this.set('checked', null);
        }
      };

      EntryModel.prototype.toggleCheck = function() {
        if (this.get('checked') != null) {
          return this.unCheck();
        } else {
          return this.check();
        }
      };

      return EntryModel;

    })(Backbone.Model);
    return EntryModel;
  };
  EntryCollectionFactory = function(todolistid) {
    var EntryCollection, mapfunc, pouchdbOptions;
    console.debug('EntryCollectionFactory:' + todolistid);
    console.debug(typeof todolistid);
    mapfunc = function(doc) {
      if ((doc.type != null) && (doc["todolist-id"] != null)) {
        if (doc.type === 'todoentry') {
          return emit(doc["todolist-id"], doc.pos);
        }
      }
    };
    pouchdbOptions = {
      db: PouchDB('svh_todo', {
        adapter: 'websql'
      }),
      fetch: 'query',
      options: {
        query: {
          include_docs: true,
          fun: {
            map: mapfunc
          },
          key: todolistid
        }
      }
    };
    console.debug(pouchdbOptions);
    EntryCollection = (function(_super) {
      __extends(EntryCollection, _super);

      function EntryCollection() {
        return EntryCollection.__super__.constructor.apply(this, arguments);
      }

      EntryCollection.prototype.model = EntryModelFactory(todolistid);

      EntryCollection.prototype.sync = BackbonePouch.sync(pouchdbOptions);

      EntryCollection.prototype["todolist-id"] = todolistid;

      EntryCollection.prototype.comparator = 'created';

      EntryCollection.prototype.parse = function(result) {
        console.debug('parse');
        console.debug(result);
        return _.pluck(result.rows, 'doc');
      };

      return EntryCollection;

    })(Backbone.Collection);
    return EntryCollection;
  };
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.EntryItemView = EntryItemView;
  App.TodoListApp.classes.EntryCollectionView = EntryCollectionView;
  App.TodoListApp.classes.EntryCollectionFactory = EntryCollectionFactory;
  App.TodoListApp.classes.EntryModelFactory = EntryModelFactory;
  App.TodoListApp.classes.EntryModel = void 0;
  App.TodoListApp.classes.EntryCollection = void 0;
  EntriesView.run = function() {
    console.debug("EntriesView.run");
    console.debug(App);
    console.debug(App.TodolistApp);
    return App.TodoListApp.entryCollection = void 0;
  };
  EntriesView.addInitializer(function() {
    return EntriesView.run();
  });
  EntriesView.on("start", function() {
    console.debug("EntriesView.onStart");
    return true;
  });
  EntriesView.on('all', function(a) {
    return console.log('EntriesView events ' + a);
  });
  App.vent.on('todolist:deleted-list', function(a) {
    if (App.TodoListApp.entryCollection != null) {
      if (a === App.TodoListApp.entryCollection["todolist-id"]) {
        App.TodoListApp.mainView.entriesView.reset();
        App.TodoListApp.mainView.entryInput.reset();
        return App.TodoListApp.entryCollection = null;
      }
    }
  });
  return App.vent.on('todolist:changelist', function(todolistmodel) {
    var todolistid;
    console.debug('todolist:changelist EntriesView');
    console.debug(todolistmodel.id);
    todolistid = todolistmodel.id;
    if (!App.TodoListApp.mainView.entryInput.hasView()) {
      App.TodoListApp.EntryInput.run();
    }
    App.TodoListApp.classes.EntryModel = App.TodoListApp.classes.EntryModelFactory(todolistid);
    App.TodoListApp.classes.EntryCollection = App.TodoListApp.classes.EntryCollectionFactory(todolistid);
    EntriesView.mainView = new EntryCollectionView({
      collection: new App.TodoListApp.classes.EntryCollection(todolistid)
    });
    EntriesView.mainView.collection.reset();
    App.TodoListApp.mainView.entriesView.show(EntriesView.mainView);
    App.TodoListApp.entryCollection = EntriesView.mainView.collection;
    EntriesView.mainView.collection.fetch();
    return void 0;
  });
});

App.module('TodoListApp.Configuration', function(Configuration, App, Backbone, Marionette, $, _) {
  var ConfigurationView, TodoConfigurationCollection, TodoConfigurationModel, configurationErrorOnLoad, configurationLoaded;
  TodoConfigurationModel = (function(_super) {
    __extends(TodoConfigurationModel, _super);

    function TodoConfigurationModel() {
      return TodoConfigurationModel.__super__.constructor.apply(this, arguments);
    }

    TodoConfigurationModel.prototype.defaults = {
      continuousreplication: false,
      username: "Rodosch",
      replicateurl: null,
      replicationinterval: 5 * 60,
      deleteCheckedEntries: 5 * 24 * 60 * 60,
      deleteUnusedEntries: 24 * 60 * 60
    };

    TodoConfigurationModel.prototype.validate = function(attributes, options) {
      var returnValue, urlRegEx;
      console.debug('validate');
      console.debug(attributes);
      console.debug(options);
      returnValue = [];
      if ((attributes.username == null) || !_.isString(attributes.username) || attributes.username.trim().length === 0) {
        returnValue.push('username');
      }
      urlRegEx = /^(https?:\/\/)(?:\S+(?::\S*)?@)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/i;
      if ((attributes.replicateurl == null) || !_.isString(attributes.replicateurl) || (attributes.replicateurl.trim().length = 0)) {

      } else {
        if (!urlRegEx.test(attributes.replicateurl)) {
          returnValue.push('replicateurl');
        }
      }
      if (returnValue.length === 0) {
        return void 0;
      } else {
        return returnValue;
      }
    };

    return TodoConfigurationModel;

  })(Backbone.Model);
  TodoConfigurationCollection = (function(_super) {
    __extends(TodoConfigurationCollection, _super);

    function TodoConfigurationCollection() {
      return TodoConfigurationCollection.__super__.constructor.apply(this, arguments);
    }

    TodoConfigurationCollection.prototype.localStorage = new Backbone.LocalStorage("TodoListApp");

    TodoConfigurationCollection.prototype.model = TodoConfigurationModel;

    return TodoConfigurationCollection;

  })(Backbone.Collection);
  Configuration.todoConfiguration = {};
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.TodoConfigurationCollection = TodoConfigurationCollection;
  App.TodoListApp.classes.TodoConfigurationModel = TodoConfigurationModel;
  ConfigurationView = (function(_super) {
    __extends(ConfigurationView, _super);

    function ConfigurationView() {
      return ConfigurationView.__super__.constructor.apply(this, arguments);
    }

    ConfigurationView.prototype.tagName = "form";

    ConfigurationView.prototype.setValues = function() {
      var field, _i, _len, _ref, _results;
      console.debug('ConfigurationView.setValues');
      console.debug(this.model.toJSON());
      console.debug(this.$('input.username'));
      this.$('input.username').val(this.model.get('username'));
      console.debug(this.$('input.replicateurl'));
      this.$('input.replicateurl').val(this.model.get('replicateurl'));
      console.debug(this.$('input.continuousreplication'));
      this.$('input.continuousreplication').prop('checked', this.model.get('continuousreplication'));
      console.debug(this.$('input.replicationinterval'));
      this.$('input.replicationinterval').val(this.model.get('replicationinterval'));
      console.debug(this.$('input.delete-checked-entries'));
      this.$('input.delete-checked-entries').val(this.model.get('deleteCheckedEntries'));
      console.debug(this.$('input.delete-unused-entries'));
      this.$('input.delete-unused-entries').val(this.model.get('deleteUnusedEntries'));
      if (this.model.isValid()) {
        return this.$('.form-group').removeClass('has-error');
      } else {
        _ref = this.model.validationError;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          field = _ref[_i];
          console.debug('invalid Field');
          _results.push(console.debug(field));
        }
        return _results;
      }
    };

    ConfigurationView.prototype.events = {
      'change input.username': function() {
        return this.model.save({
          username: this.$('input.username').val().trim()
        });
      },
      'change input.replicateurl': function() {
        return this.model.save({
          replicateurl: this.$('input.replicateurl').val().trim()
        });
      },
      'change input.replicationinterval': function() {
        return this.model.save({
          replicationinterval: parseInt(this.$('input.replicationinterval').val().trim())
        });
      },
      'change input.continuousreplication': function() {
        return this.model.save({
          continuousreplication: this.$('input.continuousreplication').prop('checked')
        });
      },
      'change input.delete-checked-entries': function() {
        return this.model.save({
          deleteCheckedEntries: parseInt(this.$('input.delete-checked-entries').val().trim())
        });
      },
      'change input.delete-unused-entries': function() {
        return this.model.save({
          deleteUnusedEntries: parseInt(this.$('input.delete-unused-entries').val().trim())
        });
      }
    };

    ConfigurationView.prototype.modelEvents = {
      'change': function() {
        return this.setValues();
      },
      'submit form': function() {
        console.debug('submit');
        return false;
      },
      'invalid': function() {
        var field, _i, _len, _ref, _results;
        console.debug('invalid');
        console.debug(this.model.validationError);
        _ref = this.model.validationError;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          field = _ref[_i];
          console.debug('invalid Field');
          _results.push(this.$('.form-group.' + field).addClass('has-error'));
        }
        return _results;
      }
    };

    ConfigurationView.prototype.template = _.template("<div class=\"username form-group has-error\">\n	<label class=\"control-label\" for=\"username\">Benutzername</label>\n	<input type=\"text\" class=\"form-control username\" placeholder=\"Mein Name ist??\" required />\n</div>\n<hr />\n<div class=\"replicateurl form-group has-error\">\n	<label class=\"control-label\" for=\"replicateurl\">Adresse zum Replizieren</label>\n	<input type=\"url\" class=\"form-control replicateurl\" placeholder=\"http://\" required />\n</div>\n<div class=\"continuousreplication form-group has-error\">\n	<div class=\"checkbox\">\n		<label>\n			<input type=\"checkbox\" class=\"continuousreplication\"><strong>Durchgängige Replikation</strong>\n		</label>\n	</div>\n</div>\n<div class=\"form-group replicationinterval has-error\">\n	<label class=\"control-label\" for=\"replicationinterval\">Replikationsinterval</label>\n	<div class=\"input-group\">\n		<input class=\"form-control replicationinterval\" required type=\"number\" min=\"0\" step=\"3\" placeholder=\"0\" />\n		<div class=\"input-group-btn\">\n			<button type=\"button\" class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span class=\"button-caption\">sek</span> <span class=\"caret\"></span></button>\n			<ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n				<li><a href=\"#\" class=\"sek\">sek</a></li>\n				<li><a href=\"#\" class=\"min\">min</a></li>\n				<li><a href=\"#\" class=\"h\">h</a></li>\n			</ul>\n		</div><!-- /btn-group -->\n	</div>\n</div>\n<hr />\n<div class=\"form-group delete-checked-entries has-error\">\n	<label class=\"control-label\" for=\"delete-checked-entries\">Löschen von abgearbeiteten Einträgen nach</label>\n	<div class=\"input-group\">\n		<input type=\"number\" class=\"form-control delete-checked-entries\" min=\"0\" step=\"3\" placeholder=\"0\" />\n		<div class=\"input-group-btn\">\n			<button type=\"button\" class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span class=\"button-caption\">sek</span> <span class=\"caret\"></span></button>\n			<ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n				<li><a href=\"#\" class=\"sek\">sek</a></li>\n				<li><a href=\"#\" class=\"min\">min</a></li>\n				<li><a href=\"#\" class=\"h\">h</a></li>\n			</ul>\n		</div><!-- /btn-group -->\n	</div><!-- /input-group -->\n</div><!-- /form-group -->\n<div class=\"form-group delete-unused-entries has-error\">\n	<label class=\"control-label\" for=\"delete-unused-entries\">Löschen von ungenutzen Einträgen nach</label>\n	<div class=\"input-group\">\n		<input type=\"number\" class=\"form-control delete-unused-entries\" min=\"0\" step=\"3\" placeholder=\"0\" />\n		<div class=\"input-group-btn\">\n			<button type=\"button\" class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\"><span class=\"button-caption\">sek</span> <span class=\"caret\"></span></button>\n			<ul class=\"dropdown-menu dropdown-menu-right\" role=\"menu\">\n				<li><a href=\"#\" class=\"sek\">sek</a></li>\n				<li><a href=\"#\" class=\"min\">min</a></li>\n				<li><a href=\"#\" class=\"h\">h</a></li>\n			</ul>\n		</div><!-- /btn-group -->\n	</div><!-- /input-group -->\n</div><!-- /form-group -->\n\n<hr />\n<div class=\"row\">\n	<div class=\"col-xs-6\">\n		<button type=\"reset\" class=\"btn-block btn btn-warning \">Zurücksetzen</button>\n	</div>\n	<div class=\"col-xs-6\">\n		<button type=\"submit\" class=\"btn-block btn btn-primary \">Speichern</button>\n	</div>\n</div>");

    ConfigurationView.prototype.onRender = function() {
      return this.setValues();
    };

    return ConfigurationView;

  })(Marionette.LayoutView);
  configurationLoaded = function() {
    return App.vent.trigger('todolist:configurationloaded', Configuration.todoConfiguration);
  };
  configurationErrorOnLoad = function() {
    return App.vent.trigger('todolist:configurationerroronload');
  };
  Configuration.run = function() {
    console.debug('TodoListApp.Configuration.run');
    Configuration.todoConfiguration = new TodoConfigurationCollection();
    App.reqres.setHandler("TodoListApp:Configuration", function() {
      if (Configuration.todoConfiguration.length === 0) {
        Configuration.todoConfiguration.add(new TodoConfigurationModel());
        Configuration.todoConfiguration.at(0).save(null, {
          wait: true
        });
        Configuration.todoConfiguration.at(0).on('change', function() {
          return Configuration.todoConfiguration.at(0).save();
        });
      }
      console.debug(Configuration.todoConfiguration);
      console.debug(Configuration.todoConfiguration.at(0));
      return Configuration.todoConfiguration.at(0);
    });
    return Configuration.todoConfiguration.fetch({
      wait: true
    }).done(configurationLoaded).fail(configurationErrorOnLoad);
  };
  App.mainRegion.on('before:show', function(view) {
    console.debug("App.mainregion.on 'before:show'");
    console.debug(view);

    /*
    		TODO check with instanceof
     */
    Configuration.mainView = new ConfigurationView({
      model: Configuration.todoConfiguration.at(0)
    });
    return view.configurationView.show(Configuration.mainView);
  });
  return Configuration.addInitializer(function() {
    return Configuration.run();
  });
});
