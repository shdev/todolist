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
  var TodoListAppView;
  TodoListAppView = (function(_super) {
    __extends(TodoListAppView, _super);

    function TodoListAppView() {
      return TodoListAppView.__super__.constructor.apply(this, arguments);
    }

    TodoListAppView.prototype.className = "container";

    TodoListAppView.prototype.template = _.template("<div id=\"todolistapp-lists\">\n	<div id=\"todolistapp-list-input\"></div>\n	<hr />\n	<div id=\"todolistapp-lists-view\"></div>\n</div>\n<hr />\n<hr />\n<div id=\"todolistapp-entries\">\n	<div id=\"todolistapp-entry-input\"></div>\n	<hr />\n	<div id=\"todolistapp-entries-view\"></div>\n</div>");

    TodoListAppView.prototype.regions = {
      listsArea: "#todolistapp-lists",
      listInput: "#todolistapp-list-input",
      listsView: "#todolistapp-lists-view",
      entriesArea: "#todolistapp-entries",
      entryInput: "#todolistapp-entry-input",
      entriesView: "#todolistapp-entries-view"
    };

    return TodoListAppView;

  })(Marionette.LayoutView);
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.TodoListAppView;
  TodoListApp.run = function() {
    var pouchdbRepFrom, pouchdbRepTo;
    console.debug('TodoListApp.run');
    console.debug(this);

    /*
    			TODO a better replication handling
     */
    this.pouchdb = new PouchDB('svh_todo', {
      adapter: 'websql'
    });
    this.pouchdbRepTo = this.pouchdb.replicate.to('http://192.168.50.30:5984/svh_todo', {
      live: true
    });
    this.pouchdbRepTo.on('uptodate', function(a, b, c, d) {
      console.log('@pouchdb.replicate.to.on uptodate');
      return App.vent.trigger('replication:svh_todo:uptodate');
    });
    pouchdbRepTo = this.pouchdbRepTo;
    this.pouchdbRepTo.on('error', function(a, b, c, d) {
      console.log('@pouchdb.replicate.to.on error');
      console.log(a);
      return pouchdbRepTo.cancel();
    });
    this.pouchdbRepTo.on('complete', function(a, b, c, d) {
      console.log('@pouchdb.replicate.to.on complete');
      console.log(a);
      if (App.TodoListApp.listCollection != null) {
        return App.TodoListApp.listCollection.fetch();
      }
    });
    this.pouchdbRepFrom = this.pouchdb.replicate.from('http://192.168.50.30:5984/svh_todo', {
      live: true
    });
    this.pouchdbRepFrom.on('uptodate', function(a, b, c, d) {
      console.log('@pouchdb.replicate.from.on uptodate');
      return App.vent.trigger('replication:svh_todo:uptodate');
    });
    pouchdbRepFrom = this.pouchdbRepFrom;
    this.pouchdbRepFrom.on('error', function(a, b, c, d) {
      console.log('@pouchdb.replicate.from.on error');
      console.log(a);
      return pouchdbRepFrom.cancel();
    });
    this.pouchdbRepFrom.on('complete', function(a, b, c, d) {
      console.log('@pouchdb.replicate.from.on complete');
      console.log(a);
      if (App.TodoListApp.listCollection != null) {
        return App.TodoListApp.listCollection.fetch();
      }
    });
    this.mainView = new TodoListAppView();
    console.debug(this.mainView);
    window.TodoListApp = this;
    App.mainRegion.show(this.mainView);
    console.debug(this.mainView.entryInput);
    console.debug(App.TodoListApp.mainView.entryInput);
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
  TodoListApp.on('all', function(a) {
    return console.log('TodoListApp events' + a);
  });
  return App.addInitializer(function() {
    console.debug(this);
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
  ListInput.on('all', function(a) {
    return console.log('ListInput events' + a);
  });
  return ListInput.addInitializer(function() {
    return ListInput.run();
  });
});

App.module('TodoListApp.ListsView', function(ListsView, App, Backbone, Marionette, $, _) {
  var ListCollection, ListCollectionView, ListItemView, ListModel, pouchdbOptions;
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
  ListsView.addInitializer(function() {
    return this.run();
  });
  App.vent.on('todolist:changelist', function(todolistmodel) {
    console.debug('todolist:changelist ListsView');
    console.debug(todolistmodel.id);
    return todolistmodel.correspondingView.clicked();
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

    NoEntrieView.prototype.onRender = function() {
      return console.debug('Render NoEntrieView ');
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
  var TodoConfiguration;
  TodoConfiguration = (function(_super) {
    __extends(TodoConfiguration, _super);

    function TodoConfiguration() {
      return TodoConfiguration.__super__.constructor.apply(this, arguments);
    }

    TodoConfiguration.prototype.localStorage = new Backbone.LocalStorage("TodoListApp");

    return TodoConfiguration;

  })(Backbone.Collection);
  Configuration.todoConfiguration = {};
  if (App.TodoListApp.classes == null) {
    App.TodoListApp.classes = {};
  }
  App.TodoListApp.classes.TodoConfiguration = TodoConfiguration;
  Configuration.run = function() {
    console.debug('TodoListApp.Configuration.run');
    Configuration.todoConfiguration = new TodoConfiguration();
    App.reqres.setHandler("TodoListApp:Configuration", function() {
      return Configuration.todoConfiguration;
    });
    return Configuration.todoConfiguration.fetch().done(function() {
      return App.vent.trigger('todolist:configurationloaded');
    });
  };
  return Configuration.addInitializer(function() {
    return Configuration.run();
  });
});
