# Todolist

It's an old topic but a good project to start with a new programming language or database. With this project I want to become familiar with CoffeeScript, CouchDB/PouchDB, 

## Used libraries 

* [PouchDB](http://pouchdb.com), here I used the this commit [e56d07f](https://github.com/pouchdb/pouchdb/commit/e56d07f)
* [jQuery 2.x](http://jquery.com)
* [Underscore.js](http://underscorejs.org)
* [Backone.js](http://backbonejs.org)
* [Backbone local storage adapter](https://github.com/jeromegn/Backbone.localStorage)
* [Backbone PouchDB adapter](https://github.com/jo/backbone-pouch)
* [Marionette.js](http://marionettejs.com)
* [Bootstrap](http://getbootstrap.com)
* [Bootstrap editable](https://vitalets.github.io/x-editable/)
* [Moment JS](http://momentjs.com)
* [Numeral JS](http://numeraljs.com)
* [Font-Awsome](https://fortawesome.github.io/Font-Awesome/)

## Needed programms

* [CoffeeScript](http://coffeescript.org)
* [SCSS/ SASS](http://sass-lang.com)
* [Compass](http://compass-style.org)
* [CouchDB](http://couchdb.apache.org)

## How to compile

`coffee -b -j js/todolist.js -c coffee/todolistmain.coffee coffee/GeneralBehavior.coffee  coffee/TodoListApp.coffee coffee/TodoListApp.EntryInput.coffee coffee/TodoListApp.ListInput.coffee  coffee/TodoListApp.ListsView.coffee coffee/TodoListApp.EntriesView.coffee coffee/TodoListApp.Configuration.coffee coffee/TodoListApp.TopBar.coffee`

`compass compile`

or enable compile on file change with the build in watch funtions

`coffee -b -j js/todolist.js -cw coffee/todolistmain.coffee coffee/GeneralBehavior.coffee  coffee/TodoListApp.coffee coffee/TodoListApp.EntryInput.coffee coffee/TodoListApp.ListInput.coffee  coffee/TodoListApp.ListsView.coffee coffee/TodoListApp.EntriesView.coffee coffee/TodoListApp.Configuration.coffee coffee/TodoListApp.TopBar.coffee &` 

`compass watch &`
