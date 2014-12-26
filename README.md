# Todolist

A todo list that syncs over devices with a [CP]ouchDB in the back.

## The project

I liked Wunderlist as todo list.
But I don't liked that they have my todos.
So I only want to share my todos with my wife and over our devices.
For this reason the web app should work on PCs as well as on IOS/ Android devices.
I focused on webkit engines of latest version.
For the syncing mechanism I use CouchDB, because I like the project and wanted to start with at least a small project.
In addition to that I also wanted to start with CoffeeScript, because of the Python like syntax.
The next thing I want to to try is to work with Python so now there is a commandline tool made with Python 3.4.

## Needed programms

* [CoffeeScript](http://coffeescript.org)
* [SCSS/ SASS](http://sass-lang.com)
* [Compass](http://compass-style.org)
* [CouchDB](http://couchdb.apache.org)

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

## How to compile

`coffee -b -j js/todolist.js -c coffee/todolistmain.litcoffee coffee/GeneralBehavior.coffee  coffee/TodoListApp.coffee coffee/TodoListApp.EntryInput.coffee coffee/TodoListApp.ListInput.coffee  coffee/TodoListApp.ListsView.coffee coffee/TodoListApp.EntriesView.coffee coffee/TodoListApp.Configuration.coffee coffee/TodoListApp.TopBar.coffee`

`compass compile`

or enable compile on file change with the build in watch funtions

`coffee -b -j js/todolist.js -cw coffee/todolistmain.litcoffee coffee/GeneralBehavior.coffee  coffee/TodoListApp.coffee coffee/TodoListApp.EntryInput.coffee coffee/TodoListApp.ListInput.coffee  coffee/TodoListApp.ListsView.coffee coffee/TodoListApp.EntriesView.coffee coffee/TodoListApp.Configuration.coffee coffee/TodoListApp.TopBar.coffee &` 

`compass watch &`

## Preliminaries 

For the indizies it is needed to create the following desing documents in your [CP]ouchDB

```json
{
   "_id": "_design/todolist",
   "language": "javascript",
   "views": {
       "lists": {
           "map": "function(doc) {\n  if (doc.type == 'todolist')\n\temit(doc.created, doc.name)\n}"
       },
       "entries": {
           "map": "function(doc) {\n   if (doc.type && doc[\"todolist-id\"] && doc.type == 'todoentry' )\n\temit(doc[\"todolist-id\"], doc.name) \n}"
       },
       "checked_entries": {
           "map": "function(doc) {\n   if (doc.type && doc[\"todolist-id\"] && doc.type == 'todoentry' && doc.checked != null)\n\temit(doc.checked) \n}"
       }
   }
}
```



