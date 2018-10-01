prop = require 'mithril/stream'
helpers = require 'helpers'
Todo = require 'models/model'
Todos = require 'models/collection'

module.exports = class Controller
  constructor: (attrs) ->
    @status = prop attrs.status
    @title = prop ''
    @todos = new Todos()

  update: (attrs) => @status attrs.status

  isEmpty: => not @title()
  data: => title: @title()
  resetData: => @title ''
  hasChanged: (todo) ->
    changedTitle = todo.title() isnt todo.previousTitle
    changedCompleted = todo.completed() isnt todo.previousCompleted
    changedTitle or changedCompleted

  add: =>
    unless @isEmpty()
      todo = new Todo @data()
      @todos.list.push todo
      @todos.save()
      @resetData()

  remove: (todo, pred) =>
    pred = pred or (_todo) -> _todo.id() is todo.id()
    @todos.list = helpers.filter @todos.list, pred, true
    @todos.save()

  edit: (todo) ->
    todo.previousTitle = todo.title()
    todo.previousCompleted = todo.completed()
    todo.editing true

  isVisible: (todo) =>
    switch @status()
      when 'active' then not todo.completed()
      when 'completed' then todo.completed()
      else true

  toggle: (todo) ->
    todo.previousCompleted = todo.completed()
    todo.completed not todo.completed()
    @todos.save()

  save: (todo) =>
    if todo.editing()
      todo.editing false

      if todo.isEmpty()
        @remove todo
      else if @hasChanged todo
        @todos.save()

  reset: (todo) ->
    todo.title todo.previousTitle
    todo.editing false

  clearTitle: => @title ''

  clearCompleted: => @remove null, (todo) -> todo?.completed()

  completed: =>
    filtered = helpers.filter @todos.list, (todo) -> todo?.completed()
    filtered.length

  remaining: =>
    filtered = helpers.filter @todos.list, (todo) ->
      todo and not todo.completed()

    filtered.length

  allCompleted: => @todos.list.every (todo) -> todo?.completed()

  completeAll: =>
    completed = not @allCompleted()

    for todo in @todos.list
      if todo.completed() isnt completed
        @toggle todo

  focus: (vnode, todo) ->
    if todo.editing() and vnode.dom isnt document.activeElement
      vnode.dom.focus()
