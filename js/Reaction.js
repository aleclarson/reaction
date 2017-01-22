// Generated by CoffeeScript 1.11.1
var Event, Reaction, Tracker, Type, isType, type;

Tracker = require("tracker");

isType = require("isType");

Event = require("Event");

Type = require("Type");

type = Type("Reaction");

type.trace();

type.initArgs(function(args) {
  if (isType(args[0], Function)) {
    args[0] = {
      get: args[0],
      didSet: args[1]
    };
  }
});

type.defineOptions({
  get: Function.isRequired,
  didSet: Function,
  keyPath: String
});

type.defineFrozenValues(function(options) {
  return {
    _get: options.get,
    _didSet: Event(options.didSet)
  };
});

type.defineValues(function(options) {
  return {
    _keyPath: options.keyPath,
    _computation: null
  };
});

type.initInstance(function() {
  return Reaction.didInit.emit(this);
});

type.defineBoundMethods({
  _update: function() {
    var newValue;
    newValue = this._get();
    Tracker.nonreactive(this, function() {
      return this._didSet.emit(newValue);
    });
  }
});

type.defineGetters({
  isActive: function() {
    if (this._computation) {
      return this._computation.isActive;
    } else {
      return false;
    }
  },
  didSet: function() {
    return this._didSet.listenable;
  }
});

type.definePrototype({
  keyPath: {
    get: function() {
      return this._keyPath;
    },
    set: function(keyPath) {
      var ref;
      this._keyPath = keyPath;
      return (ref = this._computation) != null ? ref.keyPath = keyPath : void 0;
    }
  }
});

type.defineMethods({
  start: function() {
    if (this._computation == null) {
      this._computation = Tracker.Computation(this._update, {
        keyPath: this.keyPath,
        sync: true
      });
    }
    this._computation.start();
    return this;
  },
  stop: function() {
    var ref;
    if ((ref = this._computation) != null) {
      ref.stop();
    }
  }
});

type.defineStatics({
  didInit: Event()
});

module.exports = Reaction = type.build();
