// Generated by CoffeeScript 1.7.1

/* https://gist.github.com/alecperkins/3363111 */

(function() {
  var App, init,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App = new Marionette.Application();

  App.addRegions({
    mainRegion: 'body'
  });

  init = function() {
    return App.start();
  };

  $(init);

  App.module('TodoListApp', function(TodoListApp, App, Backbone, Marionette, $, _) {
    var MainView;
    MainView = (function(_super) {
      __extends(MainView, _super);

      function MainView() {
        return MainView.__super__.constructor.apply(this, arguments);
      }

      MainView.prototype.className = "container";

      MainView.prototype.template = _.template("<div id=\"todolistapp-lists\">\n	<div id=\"todolistapp-list-input\"></div>\n	<div id=\"todolistapp-lists-view\"></div>\n</div>\n<div id=\"todolistapp-entries\">\n	<div id=\"todolistapp-entry-input\"></div>\n	<div id=\"todolistapp-entries-view\"></div>\n</div>");

      MainView.prototype.regions = {
        listsArea: "#todolistapp-lists",
        listInput: "#todolistapp-list-input",
        listsView: "#todolistapp-lists-view",
        entriesArea: "#todolistapp-entries",
        entryInput: "#todolistapp-entry-input",
        entriesView: "#todolistapp-entries-view"
      };

      return MainView;

    })(Marionette.LayoutView);
    TodoListApp.run = function() {
      this.mainView = new MainView();
      window.mainView = this.mainView;
      App.mainRegion.show(this.mainView);
      return App.vent.trigger('app:initialized', App);
    };
    return App.addInitializer(function() {
      return TodoListApp.run();
    });
  });

  App.module('TodoListApp.EntryInput', function(EntryInput, App, Backbone, Marionette, $, _) {
    var MainView;
    MainView = (function(_super) {
      __extends(MainView, _super);

      function MainView() {
        return MainView.__super__.constructor.apply(this, arguments);
      }

      MainView.prototype.template = _.template("<input type=\"text\" />");

      return MainView;

    })(Marionette.LayoutView);
    EntryInput.run = function() {
      console.debug('TodoListApp.EntryInput');
      this.mainView = new MainView();
      console.debug(App);
      console.debug(App.TodoListApp);
      return App.TodoListApp.mainView.entryInput.show(this.mainView);
    };
    return EntryInput.addInitializer(EntryInput.run);
  });

}).call(this);
