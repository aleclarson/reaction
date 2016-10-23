
emptyFunction = require "emptyFunction"
Tracker = require "tracker"
isType = require "isType"
Event = require "Event"
isDev = require "isDev"
Type = require "Type"
bind = require "bind"

type = Type "Reaction"

type.trace()

type.initArgs (args) ->
  if isType args[0], Function
    args[0] = get: args[0]
  return

type.defineOptions
  get: Function.isRequired
  didSet: Function
  cacheResult: Boolean.withDefault no
  needsChange: Boolean.withDefault yes
  keyPath: String

type.defineFrozenValues (options) ->

  _get: options.get

  _dep: Tracker.Dependency() if options.cacheResult

  _didSet: Event {async: no, callback: options.didSet}

type.defineValues (options) ->

  _keyPath: options.keyPath

  _value: null if options.cacheResult

  _computation: null

  _cacheResult: options.cacheResult

  _needsChange: options.needsChange if options.cacheResult

#
# Prototype
#

type.defineGetters

  value: ->
    if isDev and not @_cacheResult
      throw Error "This reaction does not cache its result!"
    if Tracker.isActive
      @_dep.depend()
    return @_value

  isActive: ->
    if @_computation
    then @_computation.isActive
    else no

  didSet: -> @_didSet.listenable

type.definePrototype

  keyPath:
    get: -> @_keyPath
    set: (keyPath) ->
      @_keyPath = keyPath
      @_computation and @_computation.keyPath = keyPath

type.defineMethods

  start: ->
    return this if @isActive
    @_computation ?= Tracker.Computation
      func: bind.method this, "update"
      async: no
      keyPath: @keyPath
    @_computation.start()
    return this

  stop: ->
    @_computation.stop() if @isActive
    return

  update: ->

    newValue = @_get()

    if @_cacheResult
      oldValue = @_value
      @_value = newValue
      @_dep.changed()

    Tracker.nonreactive =>
      @_didSet.emit newValue, oldValue
    return

module.exports = Reaction = type.build()
