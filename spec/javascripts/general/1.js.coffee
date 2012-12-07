return
###
Backbone-relational.js 0.6.0
(c) 2011 Paul Uithol

Backbone-relational may be freely distributed under the MIT license; see the accompanying LICENSE.txt.
For details and documentation: https://github.com/PaulUithol/Backbone-relational.
Depends on Backbone (and thus on Underscore as well): https://github.com/documentcloud/backbone.
###
((undefined_) ->
  "use strict"
  
  ###
  CommonJS shim
  ###
  _ = undefined
  Backbone = undefined
  exports = undefined
  if typeof require isnt "undefined"
    _ = require("underscore")
    Backbone = require("backbone")
    exports = module.exports = Backbone
  else
    _ = window._
    Backbone = window.Backbone
    exports = window
  Backbone.Relational = showWarnings: true
  
  ###
  Semaphore mixin; can be used as both binary and counting.
  ###
  Backbone.Semaphore =
    _permitsAvailable: null
    _permitsUsed: 0
    acquire: ->
      if @_permitsAvailable and @_permitsUsed >= @_permitsAvailable
        throw new Error("Max permits acquired")
      else
        @_permitsUsed++

    release: ->
      if @_permitsUsed is 0
        throw new Error("All permits released")
      else
        @_permitsUsed--

    isLocked: ->
      @_permitsUsed > 0

    setAvailablePermits: (amount) ->
      throw new Error("Available permits cannot be less than used permits")  if @_permitsUsed > amount
      @_permitsAvailable = amount

  
  ###
  A BlockingQueue that accumulates items while blocked (via 'block'),
  and processes them when unblocked (via 'unblock').
  Process can also be called manually (via 'process').
  ###
  Backbone.BlockingQueue = ->
    @_queue = []

  _.extend Backbone.BlockingQueue::, Backbone.Semaphore,
    _queue: null
    add: (func) ->
      if @isBlocked()
        @_queue.push func
      else
        func()

    process: ->
      @_queue.shift()()  while @_queue and @_queue.length

    block: ->
      @acquire()

    unblock: ->
      @release()
      @process()  unless @isBlocked()

    isBlocked: ->
      @isLocked()

  
  ###
  Global event queue. Accumulates external events ('add:<key>', 'remove:<key>' and 'update:<key>')
  until the top-level object is fully initialized (see 'Backbone.RelationalModel').
  ###
  Backbone.Relational.eventQueue = new Backbone.BlockingQueue()
  
  ###
  Backbone.Store keeps track of all created (and destruction of) Backbone.RelationalModel.
  Handles lookup for relations.
  ###
  Backbone.Store = ->
    @_collections = []
    @_reverseRelations = []
    @_subModels = []
    @_modelScopes = [exports]

  _.extend Backbone.Store::, Backbone.Events,
    addModelScope: (scope) ->
      @_modelScopes.push scope

    
    ###
    Add a set of subModelTypes to the store, that can be used to resolve the '_superModel'
    for a model later in 'setupSuperModel'.
    
    @param {Backbone.RelationalModel} subModelTypes
    @param {Backbone.RelationalModel} superModelType
    ###
    addSubModels: (subModelTypes, superModelType) ->
      @_subModels.push
        superModelType: superModelType
        subModels: subModelTypes


    
    ###
    Check if the given modelType is registered as another model's subModel. If so, add it to the super model's
    '_subModels', and set the modelType's '_superModel', '_subModelTypeName', and '_subModelTypeAttribute'.
    
    @param {Backbone.RelationalModel} modelType
    ###
    setupSuperModel: (modelType) ->
      _.find @_subModels or [], ((subModelDef) ->
        _.find subModelDef.subModels or [], ((subModelTypeName, typeValue) ->
          subModelType = @getObjectByName(subModelTypeName)
          if modelType is subModelType
            
            # Set 'modelType' as a child of the found superModel
            subModelDef.superModelType._subModels[typeValue] = modelType
            
            # Set '_superModel', '_subModelTypeValue', and '_subModelTypeAttribute' on 'modelType'.
            modelType._superModel = subModelDef.superModelType
            modelType._subModelTypeValue = typeValue
            modelType._subModelTypeAttribute = subModelDef.superModelType::subModelTypeAttribute
            true
        ), this
      ), this

    
    ###
    Add a reverse relation. Is added to the 'relations' property on model's prototype, and to
    existing instances of 'model' in the store as well.
    @param {Object} relation
    @param {Backbone.RelationalModel} relation.model
    @param {String} relation.type
    @param {String} relation.key
    @param {String|Object} relation.relatedModel
    ###
    addReverseRelation: (relation) ->
      exists = _.any(@_reverseRelations or [], (rel) ->
        _.all relation or [], (val, key) ->
          val is rel[key]

      )
      if not exists and relation.model and relation.type
        @_reverseRelations.push relation
        addRelation = (model, relation) ->
          model::relations = []  unless model::relations
          model::relations.push relation
          _.each model._subModels or [], ((subModel) ->
            addRelation subModel, relation
          ), this

        addRelation relation.model, relation
        @retroFitRelation relation

    
    ###
    Add a 'relation' to all existing instances of 'relation.model' in the store
    @param {Object} relation
    ###
    retroFitRelation: (relation) ->
      coll = @getCollection(relation.model)
      coll.each ((model) ->
        return  unless model instanceof relation.model
        new relation.type(model, relation)
      ), this

    
    ###
    Find the Store's collection for a certain type of model.
    @param {Backbone.RelationalModel} model
    @return {Backbone.Collection} A collection if found (or applicable for 'model'), or null
    ###
    getCollection: (model) ->
      model = model.constructor  if model instanceof Backbone.RelationalModel
      rootModel = model
      rootModel = rootModel._superModel  while rootModel._superModel
      coll = _.detect(@_collections, (c) ->
        c.model is rootModel
      )
      coll = @_createCollection(rootModel)  unless coll
      coll

    
    ###
    Find a type on the global object by name. Splits name on dots.
    @param {String} name
    @return {Object}
    ###
    getObjectByName: (name) ->
      parts = name.split(".")
      type = null
      _.find @_modelScopes or [], ((scope) ->
        type = _.reduce(parts or [], (memo, val) ->
          (if memo then memo[val] else `undefined`)
        , scope)
        true  if type and type isnt scope
      ), this
      type

    _createCollection: (type) ->
      coll = undefined
      
      # If 'type' is an instance, take its constructor
      type = type.constructor  if type instanceof Backbone.RelationalModel
      
      # Type should inherit from Backbone.RelationalModel.
      if type:: instanceof Backbone.RelationalModel
        coll = new Backbone.Collection()
        coll.model = type
        @_collections.push coll
      coll

    
    ###
    Find the attribute that is to be used as the `id` on a given object
    @param type
    @param {String|Number|Object|Backbone.RelationalModel} item
    @return {String|Number}
    ###
    resolveIdForItem: (type, item) ->
      id = (if _.isString(item) or _.isNumber(item) then item else null)
      if id is null
        if item instanceof Backbone.RelationalModel
          id = item.id
        else id = item[type::idAttribute]  if _.isObject(item)
      
      # Make all falsy values `null` (except for 0, which could be an id.. see '/issues/179')
      id = null  if not id and id isnt 0
      id

    
    ###
    @param type
    @param {String|Number|Object|Backbone.RelationalModel} item
    ###
    find: (type, item) ->
      id = @resolveIdForItem(type, item)
      coll = @getCollection(type)
      
      # Because the found object could be of any of the type's superModel
      # types, only return it if it's actually of the type asked for.
      if coll
        obj = coll.get(id)
        return obj  if obj instanceof type
      null

    
    ###
    Add a 'model' to it's appropriate collection. Retain the original contents of 'model.collection'.
    @param {Backbone.RelationalModel} model
    ###
    register: (model) ->
      coll = @getCollection(model)
      if coll
        throw new Error("Cannot instantiate more than one Backbone.RelationalModel with the same id per type!")  if coll.get(model)
        modelColl = model.collection
        coll.add model
        model.bind "destroy", @unregister, this
        model.collection = modelColl

    
    ###
    Explicitly update a model's id in it's store collection
    @param {Backbone.RelationalModel} model
    ###
    update: (model) ->
      coll = @getCollection(model)
      coll._onModelEvent "change:" + model.idAttribute, model, coll

    
    ###
    Remove a 'model' from the store.
    @param {Backbone.RelationalModel} model
    ###
    unregister: (model) ->
      model.unbind "destroy", @unregister
      coll = @getCollection(model)
      coll and coll.remove(model)

  Backbone.Relational.store = new Backbone.Store()
  
  ###
  The main Relation class, from which 'HasOne' and 'HasMany' inherit. Internally, 'relational:<key>' events
  are used to regulate addition and removal of models from relations.
  
  @param {Backbone.RelationalModel} instance
  @param {Object} options
  @param {string} options.key
  @param {Backbone.RelationalModel.constructor} options.relatedModel
  @param {Boolean|String} [options.includeInJSON=true] Serialize the given attribute for related model(s)' in toJSON, or just their ids.
  @param {Boolean} [options.createModels=true] Create objects from the contents of keys if the object is not found in Backbone.store.
  @param {Object} [options.reverseRelation] Specify a bi-directional relation. If provided, Relation will reciprocate
  the relation to the 'relatedModel'. Required and optional properties match 'options', except that it also needs
  {Backbone.Relation|String} type ('HasOne' or 'HasMany').
  ###
  Backbone.Relation = (instance, options) ->
    @instance = instance
    
    # Make sure 'options' is sane, and fill with defaults from subclasses and this object's prototype
    options = (if _.isObject(options) then options else {})
    @reverseRelation = _.defaults(options.reverseRelation or {}, @options.reverseRelation)
    @reverseRelation.type = (if not _.isString(@reverseRelation.type) then @reverseRelation.type else Backbone[@reverseRelation.type] or Backbone.Relational.store.getObjectByName(@reverseRelation.type))
    @model = options.model or @instance.constructor
    @options = _.defaults(options, @options, Backbone.Relation::options)
    @key = @options.key
    @keySource = @options.keySource or @key
    @keyDestination = @options.keyDestination or @keySource or @key
    
    # 'exports' should be the global object where 'relatedModel' can be found on if given as a string.
    @relatedModel = @options.relatedModel
    @relatedModel = Backbone.Relational.store.getObjectByName(@relatedModel)  if _.isString(@relatedModel)
    return false  unless @checkPreconditions()
    if instance
      contentKey = @keySource
      contentKey = @key  if contentKey isnt @key and typeof @instance.get(@key) is "object"
      @keyContents = @instance.get(contentKey)
      
      # Explicitly clear 'keySource', to prevent a leaky abstraction if 'keySource' differs from 'key'.
      if @keySource isnt @key
        @instance.unset @keySource,
          silent: true

      
      # Add this Relation to instance._relations
      @instance._relations.push this
    
    # Add the reverse relation on 'relatedModel' to the store's reverseRelations
    if not @options.isAutoRelation and @reverseRelation.type and @reverseRelation.key
      Backbone.Relational.store.addReverseRelation _.defaults(
        isAutoRelation: true
        model: @relatedModel
        relatedModel: @model
        reverseRelation: @options # current relation is the 'reverseRelation' for it's own reverseRelation
      , @reverseRelation) # Take further properties from this.reverseRelation (type, key, etc.)
    _.bindAll this, "_modelRemovedFromCollection", "_relatedModelAdded", "_relatedModelRemoved"
    if instance
      @initialize()
      
      # When a model in the store is destroyed, check if it is 'this.instance'.
      Backbone.Relational.store.getCollection(@instance).bind "relational:remove", @_modelRemovedFromCollection
      
      # When 'relatedModel' are created or destroyed, check if it affects this relation.
      Backbone.Relational.store.getCollection(@relatedModel).bind("relational:add", @_relatedModelAdded).bind "relational:remove", @_relatedModelRemoved

  
  # Fix inheritance :\
  Backbone.Relation.extend = Backbone.Model.extend
  
  # Set up all inheritable **Backbone.Relation** properties and methods.
  _.extend Backbone.Relation::, Backbone.Events, Backbone.Semaphore,
    options:
      createModels: true
      includeInJSON: true
      isAutoRelation: false

    instance: null
    key: null
    keyContents: null
    relatedModel: null
    reverseRelation: null
    related: null
    _relatedModelAdded: (model, coll, options) ->
      
      # Allow 'model' to set up it's relations, before calling 'tryAddRelated'
      # (which can result in a call to 'addRelated' on a relation of 'model')
      dit = this
      model.queue ->
        dit.tryAddRelated model, options


    _relatedModelRemoved: (model, coll, options) ->
      @removeRelated model, options

    _modelRemovedFromCollection: (model) ->
      @destroy()  if model is @instance

    
    ###
    Check several pre-conditions.
    @return {Boolean} True if pre-conditions are satisfied, false if they're not.
    ###
    checkPreconditions: ->
      i = @instance
      k = @key
      m = @model
      rm = @relatedModel
      warn = Backbone.Relational.showWarnings and typeof console isnt "undefined"
      if not m or not k or not rm
        warn and console.warn("Relation=%o; no model, key or relatedModel (%o, %o, %o)", this, m, k, rm)
        return false
      
      # Check if the type in 'model' inherits from Backbone.RelationalModel
      unless m:: instanceof Backbone.RelationalModel
        warn and console.warn("Relation=%o; model does not inherit from Backbone.RelationalModel (%o)", this, i)
        return false
      
      # Check if the type in 'relatedModel' inherits from Backbone.RelationalModel
      unless rm:: instanceof Backbone.RelationalModel
        warn and console.warn("Relation=%o; relatedModel does not inherit from Backbone.RelationalModel (%o)", this, rm)
        return false
      
      # Check if this is not a HasMany, and the reverse relation is HasMany as well
      if this instanceof Backbone.HasMany and @reverseRelation.type is Backbone.HasMany
        warn and console.warn("Relation=%o; relation is a HasMany, and the reverseRelation is HasMany as well.", this)
        return false
      
      # Check if we're not attempting to create a duplicate relationship
      if i and i._relations.length
        exists = _.any(i._relations or [], (rel) ->
          hasReverseRelation = @reverseRelation.key and rel.reverseRelation.key
          rel.relatedModel is rm and rel.key is k and (not hasReverseRelation or @reverseRelation.key is rel.reverseRelation.key)
        , this)
        if exists
          warn and console.warn("Relation=%o between instance=%o.%s and relatedModel=%o.%s already exists", this, i, k, rm, @reverseRelation.key)
          return false
      true

    
    ###
    Set the related model(s) for this relation
    @param {Backbone.Mode|Backbone.Collection} related
    @param {Object} [options]
    ###
    setRelated: (related, options) ->
      @related = related
      @instance.acquire()
      @instance.set @key, related, _.defaults(options or {},
        silent: true
      )
      @instance.release()

    
    ###
    Determine if a relation (on a different RelationalModel) is the reverse
    relation of the current one.
    @param {Backbone.Relation} relation
    @return {Boolean}
    ###
    _isReverseRelation: (relation) ->
      return true  if relation.instance instanceof @relatedModel and @reverseRelation.key is relation.key and @key is relation.reverseRelation.key
      false

    
    ###
    Get the reverse relations (pointing back to 'this.key' on 'this.instance') for the currently related model(s).
    @param {Backbone.RelationalModel} [model] Get the reverse relations for a specific model.
    If not specified, 'this.related' is used.
    @return {Backbone.Relation[]}
    ###
    getReverseRelations: (model) ->
      reverseRelations = []
      
      # Iterate over 'model', 'this.related.models' (if this.related is a Backbone.Collection), or wrap 'this.related' in an array.
      models = (if not _.isUndefined(model) then [model] else @related and (@related.models or [@related]))
      _.each models or [], ((related) ->
        _.each related.getRelations() or [], ((relation) ->
          reverseRelations.push relation  if @_isReverseRelation(relation)
        ), this
      ), this
      reverseRelations

    
    ###
    Rename options.silent to options.silentChange, so events propagate properly.
    (for example in HasMany, from 'addRelated'->'handleAddition')
    @param {Object} [options]
    @return {Object}
    ###
    sanitizeOptions: (options) ->
      options = (if options then _.clone(options) else {})
      if options.silent
        options.silentChange = true
        delete options.silent
      options

    
    ###
    Rename options.silentChange to options.silent, so events are silenced as intended in Backbone's
    original functions.
    @param {Object} [options]
    @return {Object}
    ###
    unsanitizeOptions: (options) ->
      options = (if options then _.clone(options) else {})
      if options.silentChange
        options.silent = true
        delete options.silentChange
      options

    
    # Cleanup. Get reverse relation, call removeRelated on each.
    destroy: ->
      Backbone.Relational.store.getCollection(@instance).unbind "relational:remove", @_modelRemovedFromCollection
      Backbone.Relational.store.getCollection(@relatedModel).unbind("relational:add", @_relatedModelAdded).unbind "relational:remove", @_relatedModelRemoved
      _.each @getReverseRelations() or [], ((relation) ->
        relation.removeRelated @instance
      ), this

  Backbone.HasOne = Backbone.Relation.extend(
    options:
      reverseRelation:
        type: "HasMany"

    initialize: ->
      _.bindAll this, "onChange"
      @instance.bind "relational:change:" + @key, @onChange
      model = @findRelated(silent: true)
      @setRelated model
      
      # Notify new 'related' object of the new relation.
      _.each @getReverseRelations() or [], ((relation) ->
        relation.addRelated @instance
      ), this

    findRelated: (options) ->
      item = @keyContents
      model = null
      if item instanceof @relatedModel
        model = item
      else if item or item is 0 # since 0 can be a valid `id` as well
        model = @relatedModel.findOrCreate(item,
          create: @options.createModels
        )
      model

    
    ###
    If the key is changed, notify old & new reverse relations and initialize the new relation
    ###
    onChange: (model, attr, options) ->
      
      # Don't accept recursive calls to onChange (like onChange->findRelated->findOrCreate->initializeRelations->addRelated->onChange)
      return  if @isLocked()
      @acquire()
      options = @sanitizeOptions(options)
      
      # 'options._related' is set by 'addRelated'/'removeRelated'. If it is set, the change
      # is the result of a call from a relation. If it's not, the change is the result of 
      # a 'set' call on this.instance.
      changed = _.isUndefined(options._related)
      oldRelated = (if changed then @related else options._related)
      if changed
        @keyContents = attr
        
        # Set new 'related'
        if attr instanceof @relatedModel
          @related = attr
        else if attr
          related = @findRelated(options)
          @setRelated related
        else
          @setRelated null
      
      # Notify old 'related' object of the terminated relation
      if oldRelated and @related isnt oldRelated
        _.each @getReverseRelations(oldRelated) or [], ((relation) ->
          relation.removeRelated @instance, options
        ), this
      
      # Notify new 'related' object of the new relation. Note we do re-apply even if this.related is oldRelated;
      # that can be necessary for bi-directional relations if 'this.instance' was created after 'this.related'.
      # In that case, 'this.instance' will already know 'this.related', but the reverse might not exist yet.
      _.each @getReverseRelations() or [], ((relation) ->
        relation.addRelated @instance, options
      ), this
      
      # Fire the 'update:<key>' event if 'related' was updated
      if not options.silentChange and @related isnt oldRelated
        dit = this
        Backbone.Relational.eventQueue.add ->
          dit.instance.trigger "update:" + dit.key, dit.instance, dit.related, options

      @release()

    
    ###
    If a new 'this.relatedModel' appears in the 'store', try to match it to the last set 'keyContents'
    ###
    tryAddRelated: (model, options) ->
      return  if @related
      options = @sanitizeOptions(options)
      item = @keyContents
      if item or item is 0 # since 0 can be a valid `id` as well
        id = Backbone.Relational.store.resolveIdForItem(@relatedModel, item)
        @addRelated model, options  if not _.isNull(id) and model.id is id

    addRelated: (model, options) ->
      if model isnt @related
        oldRelated = @related or null
        @setRelated model
        @onChange @instance, model,
          _related: oldRelated


    removeRelated: (model, options) ->
      return  unless @related
      if model is @related
        oldRelated = @related or null
        @setRelated null
        @onChange @instance, model,
          _related: oldRelated

  )
  Backbone.HasMany = Backbone.Relation.extend(
    collectionType: null
    options:
      reverseRelation:
        type: "HasOne"

      collectionType: Backbone.Collection
      collectionKey: true
      collectionOptions: {}

    initialize: ->
      _.bindAll this, "onChange", "handleAddition", "handleRemoval", "handleReset"
      @instance.bind "relational:change:" + @key, @onChange
      
      # Handle a custom 'collectionType'
      @collectionType = @options.collectionType
      @collectionType = Backbone.Relational.store.getObjectByName(@collectionType)  if _.isString(@collectionType)
      throw new Error("collectionType must inherit from Backbone.Collection")  if not @collectionType:: instanceof Backbone.Collection
      
      # Handle cases where a model/relation is created with a collection passed straight into 'attributes'
      if @keyContents instanceof Backbone.Collection
        @setRelated @_prepareCollection(@keyContents)
      else
        @setRelated @_prepareCollection()
      @findRelated silent: true

    _getCollectionOptions: ->
      (if _.isFunction(@options.collectionOptions) then @options.collectionOptions(@instance) else @options.collectionOptions)

    
    ###
    Bind events and setup collectionKeys for a collection that is to be used as the backing store for a HasMany.
    If no 'collection' is supplied, a new collection will be created of the specified 'collectionType' option.
    @param {Backbone.Collection} [collection]
    ###
    _prepareCollection: (collection) ->
      @related.unbind("relational:add", @handleAddition).unbind("relational:remove", @handleRemoval).unbind "relational:reset", @handleReset  if @related
      collection = new @collectionType([], @_getCollectionOptions())  if not collection or (collection not instanceof Backbone.Collection)
      collection.model = @relatedModel
      if @options.collectionKey
        key = (if @options.collectionKey is true then @options.reverseRelation.key else @options.collectionKey)
        if collection[key] and collection[key] isnt @instance
          console.warn "Relation=%o; collectionKey=%s already exists on collection=%o", this, key, @options.collectionKey  if Backbone.Relational.showWarnings and typeof console isnt "undefined"
        else collection[key] = @instance  if key
      collection.bind("relational:add", @handleAddition).bind("relational:remove", @handleRemoval).bind "relational:reset", @handleReset
      collection

    findRelated: (options) ->
      if @keyContents
        models = []
        if @keyContents instanceof Backbone.Collection
          models = @keyContents.models
        else
          
          # Handle cases the an API/user supplies just an Object/id instead of an Array
          @keyContents = (if _.isArray(@keyContents) then @keyContents else [@keyContents])
          
          # Try to find instances of the appropriate 'relatedModel' in the store
          _.each @keyContents or [], ((item) ->
            model = null
            if item instanceof @relatedModel
              model = item
            else if item or item is 0 # since 0 can be a valid `id` as well
              model = @relatedModel.findOrCreate(item,
                create: @options.createModels
              )
            models.push model  if model and not @related.getByCid(model) and not @related.get(model)
          ), this
        
        # Add all found 'models' in on go, so 'add' will only be called once (and thus 'sort', etc.)
        if models.length
          options = @unsanitizeOptions(options)
          @related.add models, options

    
    ###
    If the key is changed, notify old & new reverse relations and initialize the new relation
    ###
    onChange: (model, attr, options) ->
      options = @sanitizeOptions(options)
      @keyContents = attr
      
      # Replace 'this.related' by 'attr' if it is a Backbone.Collection
      if attr instanceof Backbone.Collection
        @_prepareCollection attr
        @related = attr
      
      # Otherwise, 'attr' should be an array of related object ids.
      # Re-use the current 'this.related' if it is a Backbone.Collection, and remove any current entries.
      # Otherwise, create a new collection.
      else
        oldIds = {}
        newIds = {}
        attr = [attr]  if not _.isArray(attr) and attr isnt `undefined`
        oldIds = undefined
        _.each attr, (attributes) ->
          newIds[attributes.id] = true

        coll = @related
        if coll instanceof Backbone.Collection
          
          # Make sure to operate on a copy since we're removing while iterating
          _.each coll.models.slice(0), (model) ->
            
            # When fetch is called with the 'keepNewModels' option, we don't want to remove
            # client-created new models when the fetch is completed.
            if not options.keepNewModels or not model.isNew()
              oldIds[model.id] = true
              coll.remove model,
                silent: (model.id of newIds)


        else
          coll = @_prepareCollection()
        _.each attr, ((attributes) ->
          model = @relatedModel.findOrCreate(attributes,
            create: @options.createModels
          )
          if model
            coll.add model,
              silent: (attributes.id of oldIds)

        ), this
        @setRelated coll
      dit = this
      Backbone.Relational.eventQueue.add ->
        not options.silentChange and dit.instance.trigger("update:" + dit.key, dit.instance, dit.related, options)


    tryAddRelated: (model, options) ->
      options = @sanitizeOptions(options)
      if not @related.getByCid(model) and not @related.get(model)
        
        # Check if this new model was specified in 'this.keyContents'
        item = _.any(@keyContents or [], (item) ->
          id = Backbone.Relational.store.resolveIdForItem(@relatedModel, item)
          not _.isNull(id) and id is model.id
        , this)
        @related.add model, options  if item

    
    ###
    When a model is added to a 'HasMany', trigger 'add' on 'this.instance' and notify reverse relations.
    (should be 'HasOne', must set 'this.instance' as their related).
    ###
    handleAddition: (model, coll, options) ->
      
      #console.debug('handleAddition called; args=%o', arguments);
      # Make sure the model is in fact a valid model before continuing.
      # (it can be invalid as a result of failing validation in Backbone.Collection._prepareModel)
      return  unless model instanceof Backbone.Model
      options = @sanitizeOptions(options)
      _.each @getReverseRelations(model) or [], ((relation) ->
        relation.addRelated @instance, options
      ), this
      
      # Only trigger 'add' once the newly added model is initialized (so, has it's relations set up)
      dit = this
      Backbone.Relational.eventQueue.add ->
        not options.silentChange and dit.instance.trigger("add:" + dit.key, model, dit.related, options)


    
    ###
    When a model is removed from a 'HasMany', trigger 'remove' on 'this.instance' and notify reverse relations.
    (should be 'HasOne', which should be nullified)
    ###
    handleRemoval: (model, coll, options) ->
      
      #console.debug('handleRemoval called; args=%o', arguments);
      return  unless model instanceof Backbone.Model
      options = @sanitizeOptions(options)
      _.each @getReverseRelations(model) or [], ((relation) ->
        relation.removeRelated @instance, options
      ), this
      dit = this
      Backbone.Relational.eventQueue.add ->
        not options.silentChange and dit.instance.trigger("remove:" + dit.key, model, dit.related, options)


    handleReset: (coll, options) ->
      options = @sanitizeOptions(options)
      dit = this
      Backbone.Relational.eventQueue.add ->
        not options.silentChange and dit.instance.trigger("reset:" + dit.key, dit.related, options)


    addRelated: (model, options) ->
      dit = this
      options = @unsanitizeOptions(options)
      model.queue -> # Queued to avoid errors for adding 'model' to the 'this.related' set twice
        dit.related.add model, options  if dit.related and not dit.related.getByCid(model) and not dit.related.get(model)


    removeRelated: (model, options) ->
      options = @unsanitizeOptions(options)
      @related.remove model, options  if @related.getByCid(model) or @related.get(model)
  )
  
  ###
  A type of Backbone.Model that also maintains relations to other models and collections.
  New events when compared to the original:
  - 'add:<key>' (model, related collection, options)
  - 'remove:<key>' (model, related collection, options)
  - 'update:<key>' (model, related model or collection, options)
  ###
  Backbone.RelationalModel = Backbone.Model.extend(
    relations: null # Relation descriptions on the prototype
    _relations: null # Relation instances
    _isInitialized: false
    _deferProcessing: false
    _queue: null
    subModelTypeAttribute: "type"
    subModelTypes: null
    constructor: (attributes, options) ->
      
      # Nasty hack, for cases like 'model.get( <HasMany key> ).add( item )'.
      # Defer 'processQueue', so that when 'Relation.createModels' is used we:
      # a) Survive 'Backbone.Collection.add'; this takes care we won't error on "can't add model to a set twice"
      #    (by creating a model from properties, having the model add itself to the collection via one of
      #    it's relations, then trying to add it to the collection).
      # b) Trigger 'HasMany' collection events only after the model is really fully set up.
      # Example that triggers both a and b: "p.get('jobs').add( { company: c, person: p } )".
      dit = this
      if options and options.collection
        @_deferProcessing = true
        processQueue = (model) ->
          if model is dit
            dit._deferProcessing = false
            dit.processQueue()
            options.collection.unbind "relational:add", processQueue

        options.collection.bind "relational:add", processQueue
        
        # So we do process the queue eventually, regardless of whether this model really gets added to 'options.collection'.
        _.defer ->
          processQueue dit

      @_queue = new Backbone.BlockingQueue()
      @_queue.block()
      Backbone.Relational.eventQueue.block()
      Backbone.Model.apply this, arguments_
      
      # Try to run the global queue holding external events
      Backbone.Relational.eventQueue.unblock()

    
    ###
    Override 'trigger' to queue 'change' and 'change:*' events
    ###
    trigger: (eventName) ->
      if eventName.length > 5 and "change" is eventName.substr(0, 6)
        dit = this
        args = arguments_
        Backbone.Relational.eventQueue.add ->
          Backbone.Model::trigger.apply dit, args

      else
        Backbone.Model::trigger.apply this, arguments_
      this

    
    ###
    Initialize Relations present in this.relations; determine the type (HasOne/HasMany), then creates a new instance.
    Invoked in the first call so 'set' (which is made from the Backbone.Model constructor).
    ###
    initializeRelations: ->
      @acquire() # Setting up relations often also involve calls to 'set', and we only want to enter this function once
      @_relations = []
      _.each @relations or [], ((rel) ->
        type = (if not _.isString(rel.type) then rel.type else Backbone[rel.type] or Backbone.Relational.store.getObjectByName(rel.type))
        if type and type:: instanceof Backbone.Relation
          new type(this, rel) # Also pushes the new Relation into _relations
        else
          Backbone.Relational.showWarnings and typeof console isnt "undefined" and console.warn("Relation=%o; missing or invalid type!", rel)
      ), this
      @_isInitialized = true
      @release()
      @processQueue()

    
    ###
    When new values are set, notify this model's relations (also if options.silent is set).
    (Relation.setRelated locks this model before calling 'set' on it to prevent loops)
    ###
    updateRelations: (options) ->
      if @_isInitialized and not @isLocked()
        _.each @_relations or [], ((rel) ->
          
          # Update from data in `rel.keySource` if set, or `rel.key` otherwise
          val = @attributes[rel.keySource] or @attributes[rel.key]
          @trigger "relational:change:" + rel.key, this, val, options or {}  if rel.related isnt val
        ), this

    
    ###
    Either add to the queue (if we're not initialized yet), or execute right away.
    ###
    queue: (func) ->
      @_queue.add func

    
    ###
    Process _queue
    ###
    processQueue: ->
      @_queue.unblock()  if @_isInitialized and not @_deferProcessing and @_queue.isBlocked()

    
    ###
    Get a specific relation.
    @param key {string} The relation key to look for.
    @return {Backbone.Relation} An instance of 'Backbone.Relation', if a relation was found for 'key', or null.
    ###
    getRelation: (key) ->
      _.detect @_relations, ((rel) ->
        true  if rel.key is key
      ), this

    
    ###
    Get all of the created relations.
    @return {Backbone.Relation[]}
    ###
    getRelations: ->
      @_relations

    
    ###
    Retrieve related objects.
    @param key {string} The relation key to fetch models for.
    @param [options] {Object} Options for 'Backbone.Model.fetch' and 'Backbone.sync'.
    @param [update=false] {boolean} Whether to force a fetch from the server (updating existing models).
    @return {jQuery.when[]} An array of request objects
    ###
    fetchRelated: (key, options, update) ->
      options or (options = {})
      setUrl = undefined
      requests = []
      rel = @getRelation(key)
      keyContents = rel and rel.keyContents
      toFetch = keyContents and _.select((if _.isArray(keyContents) then keyContents else [keyContents]), (item) ->
        id = Backbone.Relational.store.resolveIdForItem(rel.relatedModel, item)
        not _.isNull(id) and (update or not Backbone.Relational.store.find(rel.relatedModel, id))
      , this)
      if toFetch and toFetch.length
        
        # Create a model for each entry in 'keyContents' that is to be fetched
        models = _.map(toFetch, (item) ->
          model = undefined
          if _.isObject(item)
            model = rel.relatedModel.findOrCreate(item)
          else
            attrs = {}
            attrs[rel.relatedModel::idAttribute] = item
            model = rel.relatedModel.findOrCreate(attrs)
          model
        , this)
        
        # Try if the 'collection' can provide a url to fetch a set of models in one request.
        setUrl = rel.related.url(models)  if rel.related instanceof Backbone.Collection and _.isFunction(rel.related.url)
        
        # An assumption is that when 'Backbone.Collection.url' is a function, it can handle building of set urls.
        # To make sure it can, test if the url we got by supplying a list of models to fetch is different from
        # the one supplied for the default fetch action (without args to 'url').
        if setUrl and setUrl isnt rel.related.url()
          opts = _.defaults(
            error: ->
              args = arguments_
              _.each models or [], (model) ->
                model.trigger "destroy", model, model.collection, options
                options.error and options.error.apply(model, args)


            url: setUrl
          , options,
            add: true
          )
          requests = [rel.related.fetch(opts)]
        else
          requests = _.map(models or [], (model) ->
            opts = _.defaults(
              error: ->
                model.trigger "destroy", model, model.collection, options
                options.error and options.error.apply(model, arguments_)
            , options)
            model.fetch opts
          , this)
      requests

    set: (key, value, options) ->
      Backbone.Relational.eventQueue.block()
      
      # Duplicate backbone's behavior to allow separate key/value parameters, instead of a single 'attributes' object
      attributes = undefined
      if _.isObject(key) or not key?
        attributes = key
        options = value
      else
        attributes = {}
        attributes[key] = value
      result = Backbone.Model::set.apply(this, arguments_)
      
      # Ideal place to set up relations :)
      if not @_isInitialized and not @isLocked()
        @constructor.initializeModelHierarchy()
        Backbone.Relational.store.register this
        @initializeRelations()
      
      # Update the 'idAttribute' in Backbone.store if; we don't want it to miss an 'id' update due to {silent:true}
      else Backbone.Relational.store.update this  if attributes and @idAttribute of attributes
      @updateRelations options  if attributes
      
      # Try to run the global queue holding external events
      Backbone.Relational.eventQueue.unblock()
      result

    unset: (attribute, options) ->
      Backbone.Relational.eventQueue.block()
      result = Backbone.Model::unset.apply(this, arguments_)
      @updateRelations options
      
      # Try to run the global queue holding external events
      Backbone.Relational.eventQueue.unblock()
      result

    clear: (options) ->
      Backbone.Relational.eventQueue.block()
      result = Backbone.Model::clear.apply(this, arguments_)
      @updateRelations options
      
      # Try to run the global queue holding external events
      Backbone.Relational.eventQueue.unblock()
      result

    
    ###
    Override 'change', so the change will only execute after 'set' has finised (relations are updated),
    and 'previousAttributes' will be available when the event is fired.
    ###
    change: (options) ->
      dit = this
      args = arguments_
      Backbone.Relational.eventQueue.add ->
        Backbone.Model::change.apply dit, args


    clone: ->
      attributes = _.clone(@attributes)
      attributes[@idAttribute] = null  unless _.isUndefined(attributes[@idAttribute])
      _.each @getRelations() or [], (rel) ->
        delete attributes[rel.key]

      new @constructor(attributes)

    
    ###
    Convert relations to JSON, omits them when required
    ###
    toJSON: (options) ->
      
      # If this Model has already been fully serialized in this branch once, return to avoid loops
      return @id  if @isLocked()
      @acquire()
      json = Backbone.Model::toJSON.call(this, options)
      json[@constructor._subModelTypeAttribute] = @constructor._subModelTypeValue  if @constructor._superModel and (@constructor._subModelTypeAttribute not of json)
      _.each @_relations or [], (rel) ->
        value = json[rel.key]
        if rel.options.includeInJSON is true
          if value and _.isFunction(value.toJSON)
            json[rel.keyDestination] = value.toJSON(options)
          else
            json[rel.keyDestination] = null
        else if _.isString(rel.options.includeInJSON)
          if value instanceof Backbone.Collection
            json[rel.keyDestination] = value.pluck(rel.options.includeInJSON)
          else if value instanceof Backbone.Model
            json[rel.keyDestination] = value.get(rel.options.includeInJSON)
          else
            json[rel.keyDestination] = null
        else if _.isArray(rel.options.includeInJSON)
          if value instanceof Backbone.Collection
            valueSub = []
            value.each (model) ->
              curJson = {}
              _.each rel.options.includeInJSON, (key) ->
                curJson[key] = model.get(key)

              valueSub.push curJson

            json[rel.keyDestination] = valueSub
          else if value instanceof Backbone.Model
            valueSub = {}
            _.each rel.options.includeInJSON, (key) ->
              valueSub[key] = value.get(key)

            json[rel.keyDestination] = valueSub
          else
            json[rel.keyDestination] = null
        else
          delete json[rel.key]
        delete json[rel.key]  if rel.keyDestination isnt rel.key

      @release()
      json
  ,
    setup: (superModel) ->
      
      # We don't want to share a relations array with a parent, as this will cause problems with
      # reverse relations.
      @::relations = (@::relations or []).slice(0)
      @_subModels = {}
      @_superModel = null
      
      # If this model has 'subModelTypes' itself, remember them in the store
      if @::hasOwnProperty("subModelTypes")
        Backbone.Relational.store.addSubModels @::subModelTypes, this
      
      # The 'subModelTypes' property should not be inherited, so reset it.
      else
        @::subModelTypes = null
      
      # Initialize all reverseRelations that belong to this new model.
      _.each @::relations or [], ((rel) ->
        rel.model = this  unless rel.model
        if rel.reverseRelation and rel.model is this
          preInitialize = true
          if _.isString(rel.relatedModel)
            
            ###
            The related model might not be defined for two reasons
            1. it never gets defined, e.g. a typo
            2. it is related to itself
            In neither of these cases do we need to pre-initialize reverse relations.
            ###
            relatedModel = Backbone.Relational.store.getObjectByName(rel.relatedModel)
            preInitialize = relatedModel and (relatedModel:: instanceof Backbone.RelationalModel)
          type = (if not _.isString(rel.type) then rel.type else Backbone[rel.type] or Backbone.Relational.store.getObjectByName(rel.type))
          new type(null, rel)  if preInitialize and type and type:: instanceof Backbone.Relation
      ), this
      this

    
    ###
    Create a 'Backbone.Model' instance based on 'attributes'.
    @param {Object} attributes
    @param {Object} [options]
    @return {Backbone.Model}
    ###
    build: (attributes, options) ->
      model = this
      
      # 'build' is a possible entrypoint; it's possible no model hierarchy has been determined yet.
      @initializeModelHierarchy()
      
      # Determine what type of (sub)model should be built if applicable.
      # Lookup the proper subModelType in 'this._subModels'.
      if @_subModels and @::subModelTypeAttribute of attributes
        subModelTypeAttribute = attributes[@::subModelTypeAttribute]
        subModelType = @_subModels[subModelTypeAttribute]
        model = subModelType  if subModelType
      new model(attributes, options)

    initializeModelHierarchy: ->
      
      # If we're here for the first time, try to determine if this modelType has a 'superModel'.
      if _.isUndefined(@_superModel) or _.isNull(@_superModel)
        Backbone.Relational.store.setupSuperModel this
        
        # If a superModel has been found, copy relations from the _superModel if they haven't been
        # inherited automatically (due to a redefinition of 'relations').
        # Otherwise, make sure we don't get here again for this type by making '_superModel' false so we fail
        # the isUndefined/isNull check next time.
        if @_superModel
          
          #
          if @_superModel::relations
            supermodelRelationsExist = _.any(@::relations or [], (rel) ->
              rel.model and rel.model isnt this
            , this)
            @::relations = @_superModel::relations.concat(@::relations)  unless supermodelRelationsExist
        else
          @_superModel = false
      
      # If we came here through 'build' for a model that has 'subModelTypes', and not all of them have been resolved yet, try to resolve each.
      if @::subModelTypes and _.keys(@::subModelTypes).length isnt _.keys(@_subModels).length
        _.each @::subModelTypes or [], (subModelTypeName) ->
          subModelType = Backbone.Relational.store.getObjectByName(subModelTypeName)
          subModelType and subModelType.initializeModelHierarchy()


    
    ###
    Find an instance of `this` type in 'Backbone.Relational.store'.
    - If `attributes` is a string or a number, `findOrCreate` will just query the `store` and return a model if found.
    - If `attributes` is an object, the model will be updated with `attributes` if found.
    Otherwise, a new model is created with `attributes` (unless `options.create` is explicitly set to `false`).
    @param {Object|String|Number} attributes Either a model's id, or the attributes used to create or update a model.
    @param {Object} [options]
    @param {Boolean} [options.create=true]
    @return {Backbone.RelationalModel}
    ###
    findOrCreate: (attributes, options) ->
      parsedAttributes = (if (_.isObject(attributes) and @::parse) then @::parse(attributes) else attributes)
      
      # Try to find an instance of 'this' model type in the store
      model = Backbone.Relational.store.find(this, parsedAttributes)
      
      # If we found an instance, update it with the data in 'item'; if not, create an instance
      # (unless 'options.create' is false).
      if _.isObject(attributes)
        if model
          model.set parsedAttributes, options
        else model = @build(attributes, options)  if not options or (options and options.create isnt false)
      model
  )
  _.extend Backbone.RelationalModel::, Backbone.Semaphore
  
  ###
  Override Backbone.Collection._prepareModel, so objects will be built using the correct type
  if the collection.model has subModels.
  ###
  Backbone.Collection::__prepareModel = Backbone.Collection::_prepareModel
  Backbone.Collection::_prepareModel = (model, options) ->
    options or (options = {})
    unless model instanceof Backbone.Model
      attrs = model
      options.collection = this
      if typeof @model.findOrCreate isnt "undefined"
        model = @model.findOrCreate(attrs, options)
      else
        model = new @model(attrs, options)
      model = false  unless model._validate(model.attributes, options)
    else model.collection = this  unless model.collection
    model

  
  ###
  Override Backbone.Collection.add, so objects fetched from the server multiple times will
  update the existing Model. Also, trigger 'relational:add'.
  ###
  add = Backbone.Collection::__add = Backbone.Collection::add
  Backbone.Collection::add = (models, options) ->
    options or (options = {})
    models = [models]  unless _.isArray(models)
    modelsToAdd = []
    
    #console.debug( 'calling add on coll=%o; model=%o, options=%o', this, models, options );
    _.each models or [], ((model) ->
      
      # `_prepareModel` attempts to find `model` in Backbone.store through `findOrCreate`,
      # and sets the new properties on it if is found. Otherwise, a new model is instantiated.
      model = Backbone.Collection::_prepareModel.call(this, model, options)  unless model instanceof Backbone.Model
      modelsToAdd.push model  if model instanceof Backbone.Model and not @get(model) and not @getByCid(model)
    ), this
    
    # Add 'models' in a single batch, so the original add will only be called once (and thus 'sort', etc).
    if modelsToAdd.length
      add.call this, modelsToAdd, options
      _.each modelsToAdd or [], ((model) ->
        @trigger "relational:add", model, this, options
      ), this
    this

  
  ###
  Override 'Backbone.Collection.remove' to trigger 'relational:remove'.
  ###
  remove = Backbone.Collection::__remove = Backbone.Collection::remove
  Backbone.Collection::remove = (models, options) ->
    options or (options = {})
    unless _.isArray(models)
      models = [models]
    else
      models = models.slice(0)
    
    #console.debug('calling remove on coll=%o; models=%o, options=%o', this, models, options );
    _.each models or [], ((model) ->
      model = @getByCid(model) or @get(model)
      if model instanceof Backbone.Model
        remove.call this, model, options
        @trigger "relational:remove", model, this, options
    ), this
    this

  
  ###
  Override 'Backbone.Collection.reset' to trigger 'relational:reset'.
  ###
  reset = Backbone.Collection::__reset = Backbone.Collection::reset
  Backbone.Collection::reset = (models, options) ->
    reset.call this, models, options
    @trigger "relational:reset", this, options
    this

  
  ###
  Override 'Backbone.Collection.sort' to trigger 'relational:reset'.
  ###
  sort = Backbone.Collection::__sort = Backbone.Collection::sort
  Backbone.Collection::sort = (options) ->
    sort.call this, options
    @trigger "relational:reset", this, options
    this

  
  ###
  Override 'Backbone.Collection.trigger' so 'add', 'remove' and 'reset' events are queued until relations
  are ready.
  ###
  trigger = Backbone.Collection::__trigger = Backbone.Collection::trigger
  Backbone.Collection::trigger = (eventName) ->
    if eventName is "add" or eventName is "remove" or eventName is "reset"
      dit = this
      args = arguments_
      if eventName is "add"
        args = _.toArray(args)
        
        # the fourth argument in case of a regular add is the option object.
        # we need to clone it, as it could be modified while we wait on the eventQueue to be unblocked
        args[3] = _.clone(args[3])  if _.isObject(args[3])
      Backbone.Relational.eventQueue.add ->
        trigger.apply dit, args

    else
      trigger.apply this, arguments_
    this

  
  # Override .extend() to automatically call .setup()
  Backbone.RelationalModel.extend = (protoProps, classProps) ->
    child = Backbone.Model.extend.apply(this, arguments_)
    child.setup this
    child
)()
