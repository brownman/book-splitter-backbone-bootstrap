return 
# documentation on writing tests here: http://docs.jquery.com/QUnit
# example tests: https://github.com/jquery/qunit/blob/master/test/same.js
# more examples: https://github.com/jquery/jquery/tree/master/test/unit
# jQueryUI examples: https://github.com/jquery/jquery-ui/tree/master/tests/unit

#sessionStorage.clear();
unless window.console
  names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml", "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"]
  window.console = {}
  i = 0

  while i < names.length
    window.console[names[i]] = ->
    ++i
$(document).ready ->
  
  # Use the 'resource_uri' if possible
  
  # Try to have the collection construct a url
  
  # Fallback to 'urlRoot'
  
  ###
  'Zoo'
  ###
  # A simple HasMany without recursive relation
  
  # For validation testing. Wikipedia says elephants are reported up to 12.000 kg. Any more, we must've weighted wrong ;).
  
  ###
  House/Person/Job/Company
  ###
  
  # Create a cozy, recursive, one-to-one relationship
  
  # A link table between 'Person' and 'Company', to achieve many-to-many relations
  initObjects = ->
    
    # Reset last ajax requests
    window.requests = []
    
    # save _reverseRelations, otherwise we'll get a lot of warnings about existing relations
    oldReverseRelations = Backbone.Relational.store._reverseRelations
    Backbone.Relational.store = new Backbone.Store()
    Backbone.Relational.store._reverseRelations = oldReverseRelations
    Backbone.Relational.eventQueue = new Backbone.BlockingQueue()
    window.person1 = new Person(
      id: "person-1"
      name: "boy"
      likesALot: "person-2"
      resource_uri: "person-1"
      user:
        id: "user-1"
        login: "dude"
        email: "me@gmail.com"
        resource_uri: "user-1"
    )
    window.person2 = new Person(
      id: "person-2"
      name: "girl"
      likesALot: "person-1"
      resource_uri: "person-2"
    )
    window.person3 = new Person(
      id: "person-3"
      resource_uri: "person-3"
    )
    window.oldCompany = new Company(
      id: "company-1"
      name: "Big Corp."
      ceo:
        name: "Big Boy"

      employees: [person: "person-3"] # uses the 'Job' link table to achieve many-to-many. No 'id' specified!
      resource_uri: "company-1"
    )
    window.newCompany = new Company(
      id: "company-2"
      name: "New Corp."
      employees: [person: "person-2"]
      resource_uri: "company-2"
    )
    window.ourHouse = new House(
      id: "house-1"
      location: "in the middle of the street"
      occupants: ["person-2"]
      resource_uri: "house-1"
    )
    window.theirHouse = new House(
      id: "house-2"
      location: "outside of town"
      occupants: []
      resource_uri: "house-2"
    )
  $.ajax = (obj) ->
    window.requests.push obj
    obj

  Backbone.Model::url = ->
    url = @get("resource_uri")
    url = (if @collection.url and _.isFunction(@collection.url) then @collection.url() else @collection.url)  if not url and @collection
    url = @urlRoot + @id  if not url and @urlRoot
    throw new Error("Url could not be determined!")  unless url
    url

  window.Zoo = Backbone.RelationalModel.extend(relations: [
    type: Backbone.HasMany
    key: "animals"
    relatedModel: "Animal"
    includeInJSON: ["id", "species"]
    collectionType: "AnimalCollection"
    collectionOptions: (instance) ->
      url: "zoo/" + instance.cid + "/animal/"

    reverseRelation:
      key: "livesIn"
      includeInJSON: "id"
  ,
    type: Backbone.HasMany
    key: "visitors"
    relatedModel: "Visitor"
  ])
  window.Animal = Backbone.RelationalModel.extend(
    urlRoot: "/animal/"
    validate: (attrs) ->
      "Too heavy."  if attrs.species is "elephant" and attrs.weight and attrs.weight > 12000
  )
  window.AnimalCollection = Backbone.Collection.extend(
    model: Animal
    initialize: (models, options) ->
      options or (options = {})
      @url = options.url
  )
  window.Visitor = Backbone.RelationalModel.extend()
  window.House = Backbone.RelationalModel.extend(relations: [
    type: Backbone.HasMany
    key: "occupants"
    relatedModel: "Person"
    reverseRelation:
      key: "livesIn"
      includeInJSON: false
  ])
  window.User = Backbone.RelationalModel.extend(urlRoot: "/user/")
  window.Person = Backbone.RelationalModel.extend(relations: [
    type: Backbone.HasOne
    key: "likesALot"
    relatedModel: "Person"
    reverseRelation:
      type: Backbone.HasOne
      key: "likedALotBy"
  ,
    type: Backbone.HasOne
    key: "user"
    keyDestination: "user_id"
    relatedModel: "User"
    includeInJSON: Backbone.Model::idAttribute
    reverseRelation:
      type: Backbone.HasOne
      includeInJSON: "name"
      key: "person"
  ,
    type: "HasMany"
    key: "jobs"
    relatedModel: "Job"
    reverseRelation:
      key: "person"
  ])
  window.PersonCollection = Backbone.Collection.extend(model: Person)
  window.Job = Backbone.RelationalModel.extend(defaults:
    startDate: null
    endDate: null
  )
  window.Company = Backbone.RelationalModel.extend(relations: [
    type: "HasMany"
    key: "employees"
    relatedModel: "Job"
    reverseRelation:
      key: "company"
  ,
    type: "HasOne"
    key: "ceo"
    relatedModel: "Person"
    reverseRelation:
      key: "runs"
  ])
  window.CompanyCollection = Backbone.Collection.extend(model: Company)
  window.Node = Backbone.RelationalModel.extend(
    urlRoot: "/node/"
    relations: [
      type: Backbone.HasOne
      key: "parent"
      relatedModel: "Node"
      reverseRelation:
        key: "children"
    ]
  )
  window.NodeList = Backbone.Collection.extend(model: Node)
  module "Backbone.Semaphore", {}
  test "Unbounded", ->
    expect 10
    semaphore = _.extend({}, Backbone.Semaphore)
    ok not semaphore.isLocked(), "Semaphore is not locked initially"
    semaphore.acquire()
    ok semaphore.isLocked(), "Semaphore is locked after acquire"
    semaphore.acquire()
    equal semaphore._permitsUsed, 2, "_permitsUsed should be incremented 2 times"
    semaphore.setAvailablePermits 4
    equal semaphore._permitsAvailable, 4, "_permitsAvailable should be 4"
    semaphore.acquire()
    semaphore.acquire()
    equal semaphore._permitsUsed, 4, "_permitsUsed should be incremented 4 times"
    try
      semaphore.acquire()
    catch ex
      ok true, "Error thrown when attempting to acquire too often"
    semaphore.release()
    equal semaphore._permitsUsed, 3, "_permitsUsed should be decremented to 3"
    semaphore.release()
    semaphore.release()
    semaphore.release()
    equal semaphore._permitsUsed, 0, "_permitsUsed should be decremented to 0"
    ok not semaphore.isLocked(), "Semaphore is not locked when all permits are released"
    try
      semaphore.release()
    catch ex
      ok true, "Error thrown when attempting to release too often"

  module "Backbone.BlockingQueue", {}
  test "Block", ->
    queue = new Backbone.BlockingQueue()
    count = 0
    increment = ->
      count++

    decrement = ->
      count--

    queue.add increment
    ok count is 1, "Increment executed right away"
    queue.add decrement
    ok count is 0, "Decrement executed right away"
    queue.block()
    queue.add increment
    ok queue.isLocked(), "Queue is blocked"
    equal count, 0, "Increment did not execute right away"
    queue.block()
    queue.block()
    equal queue._permitsUsed, 3, "_permitsUsed should be incremented to 3"
    queue.unblock()
    queue.unblock()
    queue.unblock()
    equal count, 1, "Increment executed"

  module "Backbone.Store",
    setup: initObjects

  test "Initialized", ->
    equal Backbone.Relational.store._collections.length, 5, "Store contains 5 collections"

  test "getObjectByName", ->
    equal Backbone.Relational.store.getObjectByName("Backbone"), Backbone
    equal Backbone.Relational.store.getObjectByName("Backbone.RelationalModel"), Backbone.RelationalModel

  test "Add and remove from store", ->
    coll = Backbone.Relational.store.getCollection(person1)
    length = coll.length
    person = new Person(
      id: "person-10"
      name: "Remi"
      resource_uri: "person-10"
    )
    ok coll.length is length + 1, "Collection size increased by 1"
    request = person.destroy()
    
    # Trigger the 'success' callback to fire the 'destroy' event
    request.success()
    ok coll.length is length, "Collection size decreased by 1"

  test "addModelScope", ->
    models = {}
    Backbone.Relational.store.addModelScope models
    models.Book = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "pages"
      relatedModel: "Page"
      createModels: false
      reverseRelation:
        key: "book"
    ])
    models.Page = Backbone.RelationalModel.extend()
    book = new models.Book()
    page = new models.Page(book: book)
    ok book.relations.length is 1
    ok book.get("pages").length is 1

  test "addModelScope with submodels and namespaces", ->
    ns = {}
    ns.People = {}
    Backbone.Relational.store.addModelScope ns
    ns.People.Person = Backbone.RelationalModel.extend(
      subModelTypes:
        Student: "People.Student"

      iam: ->
        "I am an abstract person"
    )
    ns.People.Student = ns.People.Person.extend(iam: ->
      "I am a student"
    )
    ns.People.PersonCollection = Backbone.Collection.extend(model: ns.People.Person)
    people = new ns.People.PersonCollection([
      name: "Bob"
      type: "Student"
    ])
    ok people.at(0).iam() is "I am a student"

  test "Models are created from objects, can then be found, destroyed, cannot be found anymore", ->
    houseId = "house-10"
    personId = "person-10"
    anotherHouse = new House(
      id: houseId
      location: "no country for old men"
      resource_uri: houseId
      occupants: [
        id: personId
        name: "Remi"
        resource_uri: personId
      ]
    )
    ok anotherHouse.get("occupants") instanceof Backbone.Collection, "Occupants is a Collection"
    ok anotherHouse.get("occupants").get(personId) instanceof Person, "Occupants contains the Person with id='" + personId + "'"
    person = Backbone.Relational.store.find(Person, personId)
    ok person, "Person with id=" + personId + " is found in the store"
    request = person.destroy()
    
    # Trigger the 'success' callback to fire the 'destroy' event
    request.success()
    person = Backbone.Relational.store.find(Person, personId)
    ok not person, personId + " is not found in the store anymore"
    ok not anotherHouse.get("occupants").get(personId), "Occupants no longer contains the Person with id='" + personId + "'"
    request = anotherHouse.destroy()
    
    # Trigger the 'success' callback to fire the 'destroy' event
    request.success()
    house = Backbone.Relational.store.find(House, houseId)
    ok not house, houseId + " is not found in the store anymore"

  test "Model.collection is the first collection a Model is added to by an end-user (not it's Backbone.Store collection!)", ->
    person = new Person(name: "New guy")
    personColl = new PersonCollection()
    personColl.add person
    ok person.collection is personColl

  test "All models can be found after adding them to a Collection via 'Collection.reset'", ->
    nodes = [
      id: 1
      parent: null
    ,
      id: 2
      parent: 1
    ,
      id: 3
      parent: 4
    ,
      id: 4
      parent: 1
    ]
    nodeList = new NodeList()
    nodeList.reset nodes
    storeColl = Backbone.Relational.store.getCollection(Node)
    equal storeColl.length, 4, "Every Node is in Backbone.Relational.store"
    ok Backbone.Relational.store.find(Node, 1) instanceof Node, "Node 1 can be found"
    ok Backbone.Relational.store.find(Node, 2) instanceof Node, "Node 2 can be found"
    ok Backbone.Relational.store.find(Node, 3) instanceof Node, "Node 3 can be found"
    ok Backbone.Relational.store.find(Node, 4) instanceof Node, "Node 4 can be found"

  test "Inheritance creates and uses a separate collection", ->
    whale = new Animal(
      id: 1
      species: "whale"
    )
    ok Backbone.Relational.store.find(Animal, 1) is whale
    numCollections = Backbone.Relational.store._collections.length
    Mammal = Animal.extend(urlRoot: "/mammal/")
    lion = new Mammal(
      id: 1
      species: "lion"
    )
    donkey = new Mammal(
      id: 2
      species: "donkey"
    )
    equal Backbone.Relational.store._collections.length, numCollections + 1
    ok Backbone.Relational.store.find(Animal, 1) is whale
    ok Backbone.Relational.store.find(Mammal, 1) is lion
    ok Backbone.Relational.store.find(Mammal, 2) is donkey
    Primate = Mammal.extend(urlRoot: "/primate/")
    gorilla = new Primate(
      id: 1
      species: "gorilla"
    )
    equal Backbone.Relational.store._collections.length, numCollections + 2
    ok Backbone.Relational.store.find(Primate, 1) is gorilla

  test "Inheritance with `subModelTypes` uses the same collection as the model's super", ->
    Mammal = Animal.extend(subModelTypes:
      primate: "Primate"
      carnivore: "Carnivore"
    )
    window.Primate = Mammal.extend()
    window.Carnivore = Mammal.extend()
    lion = new Carnivore(
      id: 1
      species: "lion"
    )
    wolf = new Carnivore(
      id: 2
      species: "wolf"
    )
    numCollections = Backbone.Relational.store._collections.length
    whale = new Mammal(
      id: 3
      species: "whale"
    )
    equal Backbone.Relational.store._collections.length, numCollections, "`_collections` should have remained the same"
    ok Backbone.Relational.store.find(Mammal, 1) is lion
    ok Backbone.Relational.store.find(Mammal, 2) is wolf
    ok Backbone.Relational.store.find(Mammal, 3) is whale
    ok Backbone.Relational.store.find(Carnivore, 1) is lion
    ok Backbone.Relational.store.find(Carnivore, 2) is wolf
    ok Backbone.Relational.store.find(Carnivore, 3) isnt whale
    gorilla = new Primate(
      id: 4
      species: "gorilla"
    )
    equal Backbone.Relational.store._collections.length, numCollections, "`_collections` should have remained the same"
    ok Backbone.Relational.store.find(Animal, 4) isnt gorilla
    ok Backbone.Relational.store.find(Mammal, 4) is gorilla
    ok Backbone.Relational.store.find(Primate, 4) is gorilla
    delete window.Primate

    delete window.Carnivore

  module "Backbone.RelationalModel",
    setup: initObjects

  test "Return values: set returns the Model", ->
    personId = "person-10"
    person = new Person(
      id: personId
      name: "Remi"
      resource_uri: personId
    )
    result = person.set(name: "Hector")
    ok result is person, "Set returns the model"

  test "getRelations", ->
    equal person1.getRelations().length, 6

  test "getRelation", ->
    rel = person1.getRelation("user")
    equal rel.key, "user"

  test "fetchRelated on a HasOne relation", ->
    errorCount = 0
    person = new Person(
      id: "person-10"
      resource_uri: "person-10"
      user: "user-10"
    )
    requests = person.fetchRelated("user",
      error: ->
        errorCount++
    )
    ok _.isArray(requests)
    equal requests.length, 1, "A request has been made"
    ok person.get("user") instanceof User
    
    # Triggering the 'error' callback should destroy the model
    requests[0].error()
    
    # Trigger the 'success' callback to fire the 'destroy' event
    window.requests[window.requests.length - 1].success()
    equal person.get("user"), null, "User has been destroyed & removed"
    equal errorCount, 1, "The error callback executed successfully"
    person2 = new Person(
      id: "person-11"
      resource_uri: "person-11"
    )
    requests = person2.fetchRelated("user")
    equal requests.length, 0, "No request was made"

  test "fetchRelated on a HasMany relation", ->
    errorCount = 0
    zoo = new Zoo(animals: ["lion-1", "zebra-1"])
    
    #
    # Case 1: separate requests for each model
    #
    requests = zoo.fetchRelated("animals",
      error: ->
        errorCount++
    )
    ok _.isArray(requests)
    equal requests.length, 2, "Two requests have been made (a separate one for each animal)"
    equal zoo.get("animals").length, 2, "Two animals in the zoo"
    
    # Triggering the 'error' callback for either request should destroy the model
    requests[0].error()
    
    # Trigger the 'success' callback to fire the 'destroy' event
    window.requests[window.requests.length - 1].success()
    equal zoo.get("animals").length, 1, "One animal left in the zoo"
    equal errorCount, 1, "The error callback executed successfully"
    
    #
    # Case 2: one request per fetch (generated by the collection)
    #
    # Give 'zoo' a custom url function that builds a url to fetch a set of models from their ids
    errorCount = 0
    zoo.get("animals").url = (models) ->
      "/animal/" + ((if models then "set/" + _.pluck(models, "id").join(";") + "/" else ""))

    
    # Set two new animals to be fetched; both should be fetched in a single request
    zoo.set animals: ["lion-2", "zebra-2"]
    equal zoo.get("animals").length, 0
    requests = zoo.fetchRelated("animals",
      error: ->
        errorCount++
    )
    ok _.isArray(requests)
    equal requests.length, 1
    ok requests[0].url is "/animal/set/lion-2;zebra-2/"
    equal zoo.get("animals").length, 2
    
    # Triggering the 'error' callback (some error occured during fetching) should trigger the 'destroy' event
    # on both fetched models, but should NOT actually make 'delete' requests to the server!
    numRequests = window.requests.length
    requests[0].error()
    ok window.requests.length is numRequests, "An error occured when fetching, but no DELETE requests are made to the server while handling local cleanup."
    equal zoo.get("animals").length, 0, "Both animals are destroyed"
    equal errorCount, 2, "The error callback executed successfully for both models"
    
    # Re-fetch them
    requests = zoo.fetchRelated("animals")
    equal requests.length, 1
    equal zoo.get("animals").length, 2
    
    # No more animals to fetch!
    requests = zoo.fetchRelated("animals")
    ok _.isArray(requests)
    equal requests.length, 0
    equal zoo.get("animals").length, 2

  test "clone", ->
    user = person1.get("user")
    
    # HasOne relations should stay with the original model
    newPerson = person1.clone()
    ok newPerson.get("user") is null
    ok person1.get("user") is user

  test "toJSON", ->
    node = new Node(
      id: "1"
      parent: "3"
      name: "First node"
    )
    new Node(
      id: "2"
      parent: "1"
      name: "Second node"
    )
    new Node(
      id: "3"
      parent: "2"
      name: "Third node"
    )
    json = node.toJSON()
    ok json.children.length is 1

  test "constructor.findOrCreate", ->
    personColl = Backbone.Relational.store.getCollection(person1)
    origPersonCollSize = personColl.length
    
    # Just find an existing model
    person = Person.findOrCreate(person1.id)
    ok person is person1
    ok origPersonCollSize is personColl.length, "Existing person was found (none created)"
    
    # Update an existing model
    person = Person.findOrCreate(
      id: person1.id
      name: "dude"
    )
    equal person.get("name"), "dude"
    equal person1.get("name"), "dude"
    ok origPersonCollSize is personColl.length, "Existing person was updated (none created)"
    
    # Look for a non-existent person; 'options.create' is false
    person = Person.findOrCreate(
      id: 5001
    ,
      create: false
    )
    ok not person
    ok origPersonCollSize is personColl.length, "No person was found (none created)"
    
    # Create a new model
    person = Person.findOrCreate(id: 5001)
    ok person instanceof Person
    ok origPersonCollSize + 1 is personColl.length, "No person was found (1 created)"

  module "Backbone.RelationalModel inheritance (`subModelTypes`)", {}
  test "Object building based on type, when using explicit collections", ->
    Mammal = Animal.extend(subModelTypes:
      primate: "Primate"
      carnivore: "Carnivore"
    )
    window.Primate = Mammal.extend()
    window.Carnivore = Mammal.extend()
    MammalCollection = AnimalCollection.extend(model: Mammal)
    mammals = new MammalCollection([
      id: 5
      species: "chimp"
      type: "primate"
    ,
      id: 6
      species: "panther"
      type: "carnivore"
    ])
    ok mammals.at(0) instanceof Primate
    ok mammals.at(1) instanceof Carnivore
    delete window.Carnivore

    delete window.Primate

  test "Object building based on type, when used in relations", ->
    PetAnimal = Backbone.RelationalModel.extend(subModelTypes:
      cat: "Cat"
      dog: "Dog"
    )
    window.Dog = PetAnimal.extend()
    window.Cat = PetAnimal.extend()
    PetPerson = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "pets"
      relatedModel: PetAnimal
      reverseRelation:
        key: "owner"
    ])
    petPerson = new PetPerson(pets: [
      type: "dog"
      name: "Spot"
    ,
      type: "cat"
      name: "Whiskers"
    ])
    ok petPerson.get("pets").at(0) instanceof Dog
    ok petPerson.get("pets").at(1) instanceof Cat
    petPerson.get("pets").add
      type: "dog"
      name: "Spot II"

    ok petPerson.get("pets").at(2) instanceof Dog
    delete window.Dog

    delete window.Cat

  test "Automatic sharing of 'superModel' relations", ->
    window.PetPerson = Backbone.RelationalModel.extend({})
    window.PetAnimal = Backbone.RelationalModel.extend(
      subModelTypes:
        dog: "Dog"

      relations: [
        type: Backbone.HasOne
        key: "owner"
        relatedModel: PetPerson
        reverseRelation:
          type: Backbone.HasMany
          key: "pets"
      ]
    )
    window.Flea = Backbone.RelationalModel.extend({})
    window.Dog = PetAnimal.extend(relations: [
      type: Backbone.HasMany
      key: "fleas"
      relatedModel: Flea
      reverseRelation:
        key: "host"
    ])
    dog = new Dog(name: "Spot")
    person = new PetPerson(pets: [dog])
    equal dog.get("owner"), person, "Dog has a working owner relation."
    flea = new Flea(host: dog)
    equal dog.get("fleas").at(0), flea, "Dog has a working fleas relation."
    delete window.PetPerson

    delete window.PetAnimal

    delete window.Flea

    delete window.Dog

  test "toJSON includes the type", ->
    window.PetAnimal = Backbone.RelationalModel.extend(subModelTypes:
      dog: "Dog"
    )
    window.Dog = PetAnimal.extend()
    dog = new Dog(name: "Spot")
    json = dog.toJSON()
    equal json.type, "dog", "The value of 'type' is the pet animal's type."
    delete window.PetAnimal

    delete window.Dog

  module "Backbone.Relation options",
    setup: initObjects

  test "'includeInJSON' (Person to JSON)", ->
    json = person1.toJSON()
    equal json.user_id, "user-1", "The value of 'user_id' is the user's id (not an object, since 'includeInJSON' is set to the idAttribute)"
    ok json.likesALot instanceof Object, "The value of 'likesALot' is an object ('includeInJSON' is 'true')"
    equal json.likesALot.likesALot, "person-1", "Person is serialized only once"
    json = person1.get("user").toJSON()
    equal json.person, "boy", "The value of 'person' is the person's name ('includeInJSON is set to 'name')"
    json = person2.toJSON()
    ok person2.get("livesIn") instanceof House, "'person2' has a 'livesIn' relation"
    equal json.livesIn, `undefined`, "The value of 'livesIn' is not serialized ('includeInJSON is 'false')"
    json = person3.toJSON()
    ok json.user_id is null, "The value of 'user_id' is null"
    ok json.likesALot is null, "The value of 'likesALot' is null"

  test "'includeInJSON' (Zoo to JSON)", ->
    zoo = new Zoo(
      name: "Artis"
      animals: [new Animal(
        id: 1
        species: "bear"
        name: "Baloo"
      ), new Animal(
        id: 2
        species: "tiger"
        name: "Shere Khan"
      )]
    )
    json = zoo.toJSON()
    equal json.animals.length, 2
    bear = json.animals[0]
    equal bear.species, "bear", "animal's species has been included in the JSON"
    equal bear.name, `undefined`, "animal's name has not been included in the JSON"

  test "'createModels' is false", ->
    NewUser = Backbone.RelationalModel.extend({})
    NewPerson = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "user"
      relatedModel: NewUser
      createModels: false
    ])
    person = new NewPerson(
      id: "newperson-1"
      resource_uri: "newperson-1"
      user:
        id: "newuser-1"
        resource_uri: "newuser-1"
    )
    ok not person.get("user")?
    user = new NewUser(
      id: "newuser-1"
      name: "SuperUser"
    )
    ok person.get("user") is user
    
    # Old data gets overwritten by the explicitly created user, since a model was never created from the old data
    ok not person.get("user").get("resource_uri")?

  test "Relations load from both `keySource` and `key`", ->
    Property = Backbone.RelationalModel.extend(idAttribute: "property_id")
    View = Backbone.RelationalModel.extend(
      idAttribute: "id"
      relations: [
        type: Backbone.HasMany
        key: "properties"
        keySource: "property_ids"
        relatedModel: Property
        reverseRelation:
          key: "view"
          keySource: "view_id"
      ]
    )
    property1 = new Property(
      property_id: 1
      key: "width"
      value: 500
      view_id: 5
    )
    view = new View(
      id: 5
      property_ids: [2]
    )
    property2 = new Property(
      property_id: 2
      key: "height"
      value: 400
    )
    
    # The values from view.property_ids should be loaded into view.properties
    ok view.get("properties") and view.get("properties").length is 2, "'view' has two 'properties'"
    ok typeof view.get("property_ids") is "undefined", "'view' does not have 'property_ids'"
    view.set "properties", [property1, property2]
    ok view.get("properties") and view.get("properties").length is 2, "'view' has two 'properties'"
    view.set "property_ids", [1, 2]
    ok view.get("properties") and view.get("properties").length is 2, "'view' has two 'properties'"

  test "'keyDestination' saves to 'key'", ->
    Property = Backbone.RelationalModel.extend(idAttribute: "property_id")
    View = Backbone.RelationalModel.extend(
      idAttribute: "id"
      relations: [
        type: Backbone.HasMany
        key: "properties"
        keyDestination: "properties_attributes"
        relatedModel: Property
        reverseRelation:
          key: "view"
          keyDestination: "view_attributes"
          includeInJSON: true
      ]
    )
    property1 = new Property(
      property_id: 1
      key: "width"
      value: 500
      view: 5
    )
    view = new View(
      id: 5
      properties: [2]
    )
    property2 = new Property(
      property_id: 2
      key: "height"
      value: 400
    )
    viewJSON = view.toJSON()
    ok viewJSON.properties_attributes and viewJSON.properties_attributes.length is 2, "'viewJSON' has two 'properties_attributes'"
    ok typeof viewJSON.properties is "undefined", "'viewJSON' does not have 'properties'"

  test "'collectionOptions' sets the options on the created HasMany Collections", ->
    zoo = new Zoo()
    ok zoo.get("animals").url is "zoo/" + zoo.cid + "/animal/"

  module "Backbone.Relation preconditions"
  test "'type', 'key', 'relatedModel' are required properties", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 0
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 0
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "listProperties"
    ])
    view = new View()
    ok view._relations.length is 0

  test "'type' can be a string or an object reference", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: "Backbone.HasOne"
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 1
    View = Backbone.RelationalModel.extend(relations: [
      type: "HasOne"
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 1
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 1

  test "'key' can be a string or an object reference", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 1
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "listProperties"
      relatedModel: Properties
    ])
    view = new View()
    ok view._relations.length is 1

  test "HasMany with a reverseRelation HasMany is not allowed", ->
    Password = Backbone.RelationalModel.extend(relations: [
      type: "HasMany"
      key: "users"
      relatedModel: "User"
      reverseRelation:
        type: "HasMany"
        key: "passwords"
    ])
    password = new Password(
      plaintext: "qwerty"
      users: ["person-1", "person-2", "person-3"]
    )
    ok password._relations.length is 0, "No _relations created on Password"

  test "Duplicate relations not allowed (two simple relations)", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
    ,
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
    ])
    view = new View()
    view.set properties: new Properties()
    ok view._relations.length is 1

  test "Duplicate relations not allowed (one relation with a reverse relation, one without)", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ,
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
    ])
    view = new View()
    view.set properties: new Properties()
    ok view._relations.length is 1

  test "Duplicate relations not allowed (two relations with reverse relations)", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ,
      type: Backbone.HasOne
      key: "properties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ])
    view = new View()
    view.set properties: new Properties()
    ok view._relations.length is 1

  test "Duplicate relations not allowed (different relations, reverse relations)", ->
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "listProperties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ,
      type: Backbone.HasOne
      key: "windowProperties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ])
    view = new View()
    prop1 = new Properties(name: "a")
    prop2 = new Properties(name: "b")
    view.set
      listProperties: prop1
      windowProperties: prop2

    ok view._relations.length is 2
    ok prop1._relations.length is 2
    ok view.get("listProperties").get("name") is "a"
    ok view.get("windowProperties").get("name") is "b"

  module "Backbone.Relation general"
  test "Only valid models (no validation failure) should be added to a relation", ->
    zoo = new Zoo()
    zoo.bind "add:animals", (animal) ->
      ok animal instanceof Animal

    smallElephant = new Animal(
      name: "Jumbo"
      species: "elephant"
      weight: 2000
      livesIn: zoo
    )
    equal zoo.get("animals").length, 1, "Just 1 elephant in the zoo"
    try
      zoo.get("animals").add
        name: "Big guy"
        species: "elephant"
        weight: 13000

    
    # Throws an error in new verions of backbone after failing validation.
    equal zoo.get("animals").length, 1, "Still just 1 elephant in the zoo"

  test "collections can also be passed as attributes on creation", ->
    animals = new AnimalCollection([
      id: 1
      species: "Lion"
    ,
      id: 2
      species: "Zebra"
    ])
    zoo = new Zoo(animals: animals)
    equal zoo.get("animals"), animals, "The 'animals' collection has been set as the zoo's animals"
    equal zoo.get("animals").length, 2, "Two animals in 'zoo'"
    zoo.destroy()
    newZoo = new Zoo(animals: animals.models)
    ok newZoo.get("animals").length is 2, "Two animals in the 'newZoo'"

  test "models can also be passed as attributes on creation", ->
    artis = new Zoo(name: "Artis")
    animal = new Animal(
      species: "Hippo"
      livesIn: artis
    )
    equal artis.get("animals").at(0), animal, "Artis has a Hippo"
    equal animal.get("livesIn"), artis, "The Hippo is in Artis"

  test "id checking handles for `undefined`, `null`, `0` ids properly", ->
    parent = new Node()
    child = new Node(parent: parent)
    equal child.get("parent"), parent
    parent.destroy()
    equal child.get("parent"), null
    
    # It used to be the case that `randomOtherNode` became `child`s parent here, since both the `parent.id`
    # (which is stored as the relation's `keyContents`) and `randomOtherNode.id` were undefined.
    randomOtherNode = new Node()
    equal child.get("parent"), null
    
    # Create a child with parent id=0, then create the parent
    child = new Node(parent: 0)
    equal child.get("parent"), null
    parent = new Node(id: 0)
    equal child.get("parent"), parent
    child.destroy()
    parent.destroy()
    
    # The other way around; create the parent with id=0, then the child
    parent = new Node(id: 0)
    equal parent.get("children").length, 0
    child = new Node(parent: 0)
    equal child.get("parent"), parent

  test "Repeated model initialization and a collection should not break existing models", ->
    dataCompanyA =
      id: "company-a"
      name: "Big Corp."
      employees: [
        id: "job-a"
      ,
        id: "job-b"
      ]

    dataCompanyB =
      id: "company-b"
      name: "Small Corp."
      employees: []

    companyA = new Company(dataCompanyA)
    
    # Attempting to instantiate another model with the same data will throw an error
    raises (->
      new Company(dataCompanyA)
    ), "Can only instantiate one model for a given `id` (per model type)"
    
    # init-ed a lead and its nested contacts are a collection
    ok companyA.get("employees") instanceof Backbone.Collection, "Company's employees should be a collection"
    equal companyA.get("employees").length, 2, "with elements"
    companyCollection = new CompanyCollection([dataCompanyA, dataCompanyB])
    
    # After loading a collection with models of the same type
    # the existing company should still have correct collections
    ok companyCollection.get(dataCompanyA.id) is companyA
    ok companyA.get("employees") instanceof Backbone.Collection, "Company's employees should still be a collection"
    equal companyA.get("employees").length, 2, "with elements"

  test "If keySource is used don't remove a model that is present in the key attribute", ->
    ForumPost = Backbone.RelationalModel.extend({})
    
    # Normally would set something here, not needed for test
    ForumPostCollection = Backbone.Collection.extend(model: ForumPost)
    Forum = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "posts"
      relatedModel: ForumPost
      collectionType: ForumPostCollection
      reverseRelation:
        key: "forum"
        keySource: "forum_id"
    ])
    TestPost = new ForumPost(
      id: 1
      title: "Hello World"
      forum:
        id: 1
        title: "Cupcakes"
    )
    TestForum = Forum.findOrCreate(1)
    notEqual TestPost.get("forum"), null, "The post's forum is not null"
    equal TestPost.get("forum").get("title"), "Cupcakes", "The post's forum title is Cupcakes"
    equal TestForum.get("title"), "Cupcakes", "A forum of id 1 has the title cupcakes"

  module "Backbone.HasOne",
    setup: initObjects

  test "HasOne relations on Person are set up properly", ->
    ok person1.get("likesALot") is person2
    equal person1.get("user").id, "user-1", "The id of 'person1's user is 'user-1'"
    ok person2.get("likesALot") is person1

  test "Reverse HasOne relations on Person are set up properly", ->
    ok person1.get("likedALotBy") is person2
    ok person1.get("user").get("person") is person1, "The person belonging to 'person1's user is 'person1'"
    ok person2.get("likedALotBy") is person1

  test "'set' triggers 'change' and 'update', on a HasOne relation, for a Model with multiple relations", ->
    expect 9
    Password = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "user"
      relatedModel: "User"
      reverseRelation:
        type: Backbone.HasOne
        key: "password"
    ])
    
    # triggers initialization of the reverse relation from User to Password
    password = new Password(plaintext: "asdf")
    person1.bind "change", (model, options) ->
      ok model.get("user") instanceof User, "model.user is an instance of User"
      equal model.previous("user").get("login"), oldLogin, "previousAttributes is available on 'change'"

    person1.bind "change:user", (model, options) ->
      ok model.get("user") instanceof User, "model.user is an instance of User"
      equal model.previous("user").get("login"), oldLogin, "previousAttributes is available on 'change'"

    person1.bind "update:user", (model, attr, options) ->
      ok model.get("user") instanceof User, "model.user is an instance of User"
      ok attr.get("person") is person1, "The user's 'person' is 'person1'"
      ok attr.get("password") instanceof Password, "The user's password attribute is a model of type Password"
      equal attr.get("password").get("plaintext"), "qwerty", "The user's password is ''qwerty'"

    user =
      login: "me@hotmail.com"
      password:
        plaintext: "qwerty"

    oldLogin = person1.get("user").get("login")
    
    # Triggers first # assertions
    person1.set user: user
    user = person1.get("user").bind("update:password", (model, attr, options) ->
      equal attr.get("plaintext"), "asdf", "The user's password is ''qwerty'"
    )
    
    # Triggers last assertion
    user.set password: password

  test "'unset' triggers 'change' and 'update:'", ->
    expect 4
    person1.bind "change", (model, options) ->
      equal model.get("user"), null, "model.user is unset"

    person1.bind "update:user", (model, attr, options) ->
      equal attr, null, "new value of attr (user) is null"

    ok person1.get("user") instanceof User, "person1 has a 'user'"
    user = person1.get("user")
    person1.unset "user"
    equal user.get("person"), null, "person1 is not set on 'user' anymore"

  test "'clear' triggers 'change' and 'update:'", ->
    expect 4
    person1.bind "change", (model, options) ->
      equal model.get("user"), null, "model.user is unset"

    person1.bind "update:user", (model, attr, options) ->
      equal attr, null, "new value of attr (user) is null"

    ok person1.get("user") instanceof User, "person1 has a 'user'"
    user = person1.get("user")
    person1.clear()
    equal user.get("person"), null, "person1 is not set on 'user' anymore"

  module "Backbone.HasMany",
    setup: initObjects

  test "Listeners on 'add'/'remove'", ->
    expect 7
    ourHouse.bind("add:occupants", (model, coll) ->
      ok model is person1, "model === person1"
    ).bind "remove:occupants", (model, coll) ->
      ok model is person1, "model === person1"

    theirHouse.bind("add:occupants", (model, coll) ->
      ok model is person1, "model === person1"
    ).bind "remove:occupants", (model, coll) ->
      ok model is person1, "model === person1"

    count = 0
    person1.bind "update:livesIn", (model, attr) ->
      if count is 0
        ok attr is ourHouse, "model === ourHouse"
      else if count is 1
        ok attr is theirHouse, "model === theirHouse"
      else ok attr is null, "model === null"  if count is 2
      count++

    ourHouse.get("occupants").add person1
    person1.set livesIn: theirHouse
    theirHouse.get("occupants").remove person1

  test "Listeners for 'add'/'remove', on a HasMany relation, for a Model with multiple relations", ->
    job1 = company: oldCompany
    job2 =
      company: oldCompany
      person: person1

    job3 = person: person1
    newJob = null
    newCompany.bind "add:employees", (model, coll) ->
      ok false, "person1 should only be added to 'oldCompany'."

    
    # Assert that all relations on a Model are set up, before notifying related models.
    oldCompany.bind "add:employees", (model, coll) ->
      newJob = model
      ok model instanceof Job
      ok model.get("company") instanceof Company and model.get("person") instanceof Person, "Both Person and Company are set on the Job instance"

    person1.bind "add:jobs", (model, coll) ->
      ok model.get("company") is oldCompany and model.get("person") is person1, "Both Person and Company are set on the Job instance"

    
    # Add job1 and job2 to the 'Person' side of the relation
    jobs = person1.get("jobs")
    jobs.add job1
    ok jobs.length is 1, "jobs.length is 1"
    newJob.destroy()
    ok jobs.length is 0, "jobs.length is 0"
    jobs.add job2
    ok jobs.length is 1, "jobs.length is 1"
    newJob.destroy()
    ok jobs.length is 0, "jobs.length is 0"
    
    # Add job1 and job2 to the 'Company' side of the relation
    employees = oldCompany.get("employees")
    employees.add job3
    ok employees.length is 2, "employees.length is 2"
    newJob.destroy()
    ok employees.length is 1, "employees.length is 1"
    employees.add job2
    ok employees.length is 2, "employees.length is 2"
    newJob.destroy()
    ok employees.length is 1, "employees.length is 1"
    
    # Create a stand-alone Job ;)
    new Job(
      person: person1
      company: oldCompany
    )
    ok jobs.length is 1 and employees.length is 2, "jobs.length is 1 and employees.length is 2"

  test "The Collections used for HasMany relations are re-used if possible", ->
    collId = ourHouse.get("occupants").id = 1
    ourHouse.get("occupants").add person1
    ok ourHouse.get("occupants").id is collId
    
    # Set a value on 'occupants' that would cause the relation to be reset.
    # The collection itself should be kept (along with it's properties)
    ourHouse.set occupants: ["person-1"]
    ok ourHouse.get("occupants").id is collId
    ok ourHouse.get("occupants").length is 1
    
    # Setting a new collection loses the original collection
    ourHouse.set occupants: new Backbone.Collection()
    ok ourHouse.get("occupants").id is `undefined`

  test "Setting a new collection or array of ids updates the relation", ->
    zoo = new Zoo()
    visitors = [name: "Paul"]
    zoo.set "visitors", visitors
    equal zoo.get("visitors").length, 1
    zoo.set "visitors", []
    equal zoo.get("visitors").length, 0

  test "Setting a custom collection in 'collectionType' uses that collection for instantiation", ->
    zoo = new Zoo()
    
    # Set values so that the relation gets filled
    zoo.set animals: [
      species: "Lion"
    ,
      species: "Zebra"
    ]
    
    # Check that the animals were created
    ok zoo.get("animals").at(0).get("species") is "Lion"
    ok zoo.get("animals").at(1).get("species") is "Zebra"
    
    # Check that the generated collection is of the correct kind
    ok zoo.get("animals") instanceof AnimalCollection

  test "Setting a new collection maintains that collection's current 'models'", ->
    zoo = new Zoo()
    animals = new AnimalCollection([
      id: 1
      species: "Lion"
    ,
      id: 2
      species: "Zebra"
    ])
    zoo.set "animals", animals
    equal zoo.get("animals").length, 2
    newAnimals = new AnimalCollection([
      id: 2
      species: "Zebra"
    ,
      id: 3
      species: "Elephant"
    ,
      id: 4
      species: "Tiger"
    ])
    zoo.set "animals", newAnimals
    equal zoo.get("animals").length, 3

  test "Models found in 'findRelated' are all added in one go (so 'sort' will only be called once)", ->
    count = 0
    sort = Backbone.Collection::sort
    Backbone.Collection::sort = ->
      count++

    AnimalCollection::comparator = $.noop
    zoo = new Zoo(animals: [
      id: 1
      species: "Lion"
    ,
      id: 2
      species: "Zebra"
    ])
    equal count, 1, "Sort is called only once"
    Backbone.Collection::sort = sort
    delete AnimalCollection::comparator

  test "Raw-models set to a hasMany relation do trigger an add event in the underlying Collection with a correct index", ->
    zoo = new Zoo()
    indexes = []
    zoo.get("animals").on "add", (collection, model, options) ->
      indexes.push options.index

    zoo.set "animals", [
      id: 1
      species: "Lion"
    ,
      id: 2
      species: "Zebra"
    ]
    equal indexes[0], 0, "First item has index 0"
    equal indexes[1], 1, "Second item has index 1"

  test "Models set to a hasMany relation do trigger an add event in the underlying Collection with a correct index", ->
    zoo = new Zoo()
    indexes = []
    zoo.get("animals").on "add", (collection, model, options) ->
      indexes.push options.index

    zoo.set "animals", [new Animal(
      id: 1
      species: "Lion"
    ), new Animal(
      id: 2
      species: "Zebra"
    )]
    equal indexes[0], 0, "First item has index 0"
    equal indexes[1], 1, "Second item has index 1"

  test "The 'collectionKey' options is used to create references on generated Collections back to its RelationalModel", ->
    zoo = new Zoo(animals: ["lion-1", "zebra-1"])
    equal zoo.get("animals").livesIn, zoo
    equal zoo.get("animals").zoo, `undefined`
    Barn = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "animals"
      relatedModel: "Animal"
      collectionType: "AnimalCollection"
      collectionKey: "barn"
      reverseRelation:
        key: "livesIn"
        includeInJSON: "id"
    ])
    barn = new Barn(animals: ["chicken-1", "cow-1"])
    equal barn.get("animals").livesIn, `undefined`
    equal barn.get("animals").barn, barn
    BarnNoKey = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "animals"
      relatedModel: "Animal"
      collectionType: "AnimalCollection"
      collectionKey: false
      reverseRelation:
        key: "livesIn"
        includeInJSON: "id"
    ])
    barnNoKey = new BarnNoKey(animals: ["chicken-1", "cow-1"])
    equal barnNoKey.get("animals").livesIn, `undefined`
    equal barnNoKey.get("animals").barn, `undefined`

  test "Handle edge-cases where the server supplies a single Object/id instead of an Array", ->
    zoo = new Zoo(animals:
      id: "lion-1"
    )
    equal zoo.get("animals").length, 1, "There is 1 animal in the zoo"
    zoo.set "animals",
      id: "lion-2"

    equal zoo.get("animals").length, 1, "There is 1 animal in the zoo"

  test "Polymorhpic relations", ->
    Location = Backbone.RelationalModel.extend()
    Locatable = Backbone.RelationalModel.extend(relations: [
      key: "locations"
      type: "HasMany"
      relatedModel: Location
      reverseRelation:
        key: "locatable"
    ])
    FirstLocatable = Locatable.extend()
    SecondLocatable = Locatable.extend()
    firstLocatable = new FirstLocatable()
    secondLocatable = new SecondLocatable()
    firstLocation = new Location(
      id: 1
      locatable: firstLocatable
    )
    secondLocation = new Location(
      id: 2
      locatable: secondLocatable
    )
    ok firstLocatable.get("locations").at(0) is firstLocation
    ok firstLocatable.get("locations").at(0).get("locatable") is firstLocatable
    ok secondLocatable.get("locations").at(0) is secondLocation
    ok secondLocatable.get("locations").at(0).get("locatable") is secondLocatable

  module "Reverse relationships",
    setup: initObjects

  test "Add and remove", ->
    equal ourHouse.get("occupants").length, 1, "ourHouse has 1 occupant"
    equal person1.get("livesIn"), null, "Person 1 doesn't live anywhere"
    ourHouse.get("occupants").add person1
    equal ourHouse.get("occupants").length, 2, "Our House has 2 occupants"
    equal person1.get("livesIn") and person1.get("livesIn").id, ourHouse.id, "Person 1 lives in ourHouse"
    person1.set livesIn: theirHouse
    equal theirHouse.get("occupants").length, 1, "theirHouse has 1 occupant"
    equal ourHouse.get("occupants").length, 1, "ourHouse has 1 occupant"
    equal person1.get("livesIn") and person1.get("livesIn").id, theirHouse.id, "Person 1 lives in theirHouse"

  test "HasOne relations to self (tree stucture)", ->
    child1 = new Node(
      id: "2"
      parent: "1"
      name: "First child"
    )
    parent = new Node(
      id: "1"
      name: "Parent"
    )
    child2 = new Node(
      id: "3"
      parent: "1"
      name: "Second child"
    )
    equal parent.get("children").length, 2
    ok parent.get("children").include(child1)
    ok parent.get("children").include(child2)
    ok child1.get("parent") is parent
    equal child1.get("children").length, 0
    ok child2.get("parent") is parent
    equal child2.get("children").length, 0

  test "Models referencing each other in the same relation", ->
    parent = new Node(id: 1)
    child = new Node(id: 2)
    child.set "parent", parent
    parent.save parent: child
    console.log parent, child

  test "HasMany relations to self (tree structure)", ->
    child1 = new Node(
      id: "2"
      name: "First child"
    )
    parent = new Node(
      id: "1"
      children: ["2", "3"]
      name: "Parent"
    )
    child2 = new Node(
      id: "3"
      name: "Second child"
    )
    equal parent.get("children").length, 2
    ok parent.get("children").include(child1)
    ok parent.get("children").include(child2)
    ok child1.get("parent") is parent
    equal child1.get("children").length, 0
    ok child2.get("parent") is parent
    equal child2.get("children").length, 0

  test "HasOne relations to self (cycle, directed graph structure)", ->
    node1 = new Node(
      id: "1"
      parent: "3"
      name: "First node"
    )
    node2 = new Node(
      id: "2"
      parent: "1"
      name: "Second node"
    )
    node3 = new Node(
      id: "3"
      parent: "2"
      name: "Third node"
    )
    ok node1.get("parent") is node3
    equal node1.get("children").length, 1
    ok node1.get("children").at(0) is node2
    ok node2.get("parent") is node1
    equal node2.get("children").length, 1
    ok node2.get("children").at(0) is node3
    ok node3.get("parent") is node2
    equal node3.get("children").length, 1
    ok node3.get("children").at(0) is node1

  test "New objects (no 'id' yet) have working relations", ->
    person = new Person(name: "Remi")
    person.set user:
      login: "1"
      email: "1"

    user1 = person.get("user")
    ok user1 instanceof User, "User created on Person"
    equal user1.get("login"), "1", "person.user is the correct User"
    user2 = new User(
      login: "2"
      email: "2"
    )
    ok user2.get("person") is null, "'user' doesn't belong to a 'person' yet"
    person.set user: user2
    ok user1.get("person") is null
    ok person.get("user") is user2
    ok user2.get("person") is person
    person2.set user: user2
    ok person.get("user") is null
    ok person2.get("user") is user2
    ok user2.get("person") is person2

  test "'Save' objects (performing 'set' multiple times without and with id)", ->
    expect 2
    person3.bind("add:jobs", (model, coll) ->
      company = model.get("company")
      ok company instanceof Company and company.get("ceo").get("name") is "Lunar boy" and model.get("person") is person3, "Both Person and Company are set on the Job instance"
    ).bind "remove:jobs", (model, coll) ->
      ok false, "'person3' should not lose his job"

    
    # Create Models from an object
    company = new Company(
      name: "Luna Corp."
      ceo:
        name: "Lunar boy"

      employees: [person: "person-3"]
    )
    
    # Backbone.save executes "model.set(model.parse(resp), options)". Set a full map over object, but now with ids.
    company.set
      id: "company-3"
      name: "Big Corp."
      ceo:
        id: "person-4"
        name: "Lunar boy"
        resource_uri: "person-4"

      employees: [
        id: "job-1"
        person: "person-3"
        resource_uri: "job-1"
      ]
      resource_uri: "company-3"


  test "Set the same value a couple of time, by 'id' and object", ->
    person1.set likesALot: "person-2"
    person1.set likesALot: person2
    ok person1.get("likesALot") is person2
    ok person2.get("likedALotBy") is person1
    person1.set likesALot: "person-2"
    ok person1.get("likesALot") is person2
    ok person2.get("likedALotBy") is person1

  test "Numerical keys", ->
    child1 = new Node(
      id: 2
      name: "First child"
    )
    parent = new Node(
      id: 1
      children: [2, 3]
      name: "Parent"
    )
    child2 = new Node(
      id: 3
      name: "Second child"
    )
    equal parent.get("children").length, 2
    ok parent.get("children").include(child1)
    ok parent.get("children").include(child2)
    ok child1.get("parent") is parent
    equal child1.get("children").length, 0
    ok child2.get("parent") is parent
    equal child2.get("children").length, 0

  test "Relations that use refs to other models (instead of keys)", ->
    child1 = new Node(
      id: 2
      name: "First child"
    )
    parent = new Node(
      id: 1
      children: [child1, 3]
      name: "Parent"
    )
    child2 = new Node(
      id: 3
      name: "Second child"
    )
    ok child1.get("parent") is parent
    equal child1.get("children").length, 0
    equal parent.get("children").length, 2
    ok parent.get("children").include(child1)
    ok parent.get("children").include(child2)
    child3 = new Node(
      id: 4
      parent: parent
      name: "Second child"
    )
    equal parent.get("children").length, 3
    ok parent.get("children").include(child3)
    ok child3.get("parent") is parent
    equal child3.get("children").length, 0

  test "Add an already existing model (reverseRelation shouldn't exist yet) to a relation as a hash", ->
    
    # This test caused a race condition to surface:
    # The 'relation's constructor initializes the 'reverseRelation', which called 'relation.addRelated' in it's 'initialize'.
    # However, 'relation's 'initialize' has not been executed yet, so it doesn't have a 'related' collection yet.
    Properties = Backbone.RelationalModel.extend({})
    View = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasMany
      key: "properties"
      relatedModel: Properties
      reverseRelation:
        type: Backbone.HasOne
        key: "view"
    ])
    props = new Properties(
      id: 1
      key: "width"
      value: "300px"
      view: 1
    )
    view = new View(
      id: 1
      properties: [
        id: 1
        key: "width"
        value: "300px"
        view: 1
      ]
    )
    ok props.get("view") is view
    ok view.get("properties").include(props)

  test "Reverse relations are found for models that have not been instantiated and use .extend()", ->
    View = Backbone.RelationalModel.extend({})
    Property = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "view"
      relatedModel: View
      reverseRelation:
        type: Backbone.HasMany
        key: "properties"
    ])
    view = new View(
      id: 1
      properties: [
        id: 1
        key: "width"
        value: "300px"
      ]
    )
    ok view.get("properties") instanceof Backbone.Collection

  test "Reverse relations found for models that have not been instantiated and run .setup() manually", ->
    
    # Generated from CoffeeScript code:
    # 	 class View extends Backbone.RelationalModel
    # 	 
    # 	 View.setup()
    # 	 
    # 	 class Property extends Backbone.RelationalModel
    # 	   relations: [
    # 	     type: Backbone.HasOne
    # 	     key: 'view'
    # 	     relatedModel: View
    # 	     reverseRelation:
    # 	       type: Backbone.HasMany
    # 	       key: 'properties'
    # 	   ]
    # 	 
    # 	 Property.setup()
    Property = undefined
    View = undefined
    __hasProp_ = {}.hasOwnProperty
    __extends_ = (child, parent) ->
      ctor = ->
        @constructor = child
      for key of parent
        child[key] = parent[key]  if __hasProp_.call(parent, key)
      ctor:: = parent::
      child:: = new ctor
      child.__super__ = parent::
      child

    View = ((_super) ->
      View = ->
        View.__super__.constructor.apply this, arguments_
      __extends_ View, _super
      View.name = "View"
      View
    )(Backbone.RelationalModel)
    View.setup()
    Property = ((_super) ->
      Property = ->
        Property.__super__.constructor.apply this, arguments_
      __extends_ Property, _super
      Property.name = "Property"
      Property::relations = [
        type: Backbone.HasOne
        key: "view"
        relatedModel: View
        reverseRelation:
          type: Backbone.HasMany
          key: "properties"
      ]
      Property
    )(Backbone.RelationalModel)
    Property.setup()
    view = new View(
      id: 1
      properties: [
        id: 1
        key: "width"
        value: "300px"
      ]
    )
    ok view.get("properties") instanceof Backbone.Collection

  test "ReverseRelations are applied retroactively", ->
    
    # Use brand new Model types, so we can be sure we don't have any reverse relations cached from previous tests
    NewUser = Backbone.RelationalModel.extend({})
    NewPerson = Backbone.RelationalModel.extend(relations: [
      type: Backbone.HasOne
      key: "user"
      relatedModel: NewUser
      reverseRelation:
        type: Backbone.HasOne
        key: "person"
    ])
    user = new NewUser(id: "newuser-1")
    
    #var user2 = new NewUser( { id: 'newuser-2', person: 'newperson-1' } );
    person = new NewPerson(
      id: "newperson-1"
      user: user
    )
    ok person.get("user") is user
    ok user.get("person") is person

  
  #console.debug( person, user );
  module "Model loading",
    setup: initObjects

  test "Loading (fetching) multiple times updates the model, and relations's `keyContents`", ->
    collA = new Backbone.Collection()
    collA.model = User
    collB = new Backbone.Collection()
    collB.model = User
    
    # Similar to what happens when calling 'fetch' on collA, updating it, calling 'fetch' on collB
    name = "User 1"
    collA.add
      id: "/user/1/"
      name: name

    user = collA.at(0)
    equal user.get("name"), name
    
    # The 'name' of 'user' is updated when adding a new hash to the collection
    name = "New name"
    collA.add
      id: "/user/1/"
      name: name

    updatedUser = collA.at(0)
    equal user.get("name"), name
    equal updatedUser.get("name"), name
    
    # The 'name' of 'user' is also updated when adding a new hash to another collection
    name = "Another new name"
    collB.add
      id: "/user/1/"
      name: name
      title: "Superuser"

    updatedUser2 = collA.at(0)
    equal user.get("name"), name
    equal updatedUser2.get("name"), name
    
    #console.log( collA.models, collA.get( '/user/1/' ), user, updatedUser, updatedUser2 );
    ok collA.get("/user/1/") is updatedUser
    ok collA.get("/user/1/") is updatedUser2
    ok collB.get("/user/1/") is user

  test "Loading (fetching) a collection multiple times updates related models as well (HasOne)", ->
    coll = new PersonCollection()
    coll.add
      id: "person-10"
      name: "Person"
      user:
        id: "user-10"
        login: "User"

    person = coll.at(0)
    user = person.get("user")
    equal user.get("login"), "User"
    coll.add
      id: "person-10"
      name: "New person"
      user:
        id: "user-10"
        login: "New user"

    equal person.get("name"), "New person"
    equal user.get("login"), "New user"

  test "Loading (fetching) a collection multiple times updates related models as well (HasMany)", ->
    coll = new Backbone.Collection()
    coll.model = Zoo
    
    # Create a 'zoo' with 1 animal in it
    coll.add
      id: "zoo-1"
      name: "Zoo"
      animals: [
        id: "lion-1"
        name: "Mufasa"
      ]

    zoo = coll.at(0)
    lion = zoo.get("animals").at(0)
    equal lion.get("name"), "Mufasa"
    
    # Update the name of 'zoo' and 'lion'
    coll.add
      id: "zoo-1"
      name: "Zoo Station"
      animals: [
        id: "lion-1"
        name: "Simba"
      ]

    equal zoo.get("name"), "Zoo Station"
    equal lion.get("name"), "Simba"

  test "Does not trigger add / remove events for existing models on bulk assignment", ->
    house = new House(
      id: "house-100"
      location: "in the middle of the street"
      occupants: [
        id: "person-5"
      ,
        id: "person-6"
      ]
    )
    eventsTriggered = 0
    house.bind("add:occupants", (model) ->
      ok false, model.id + " should not be added"
      eventsTriggered++
    ).bind "remove:occupants", (model) ->
      ok false, model.id + " should not be removed"
      eventsTriggered++

    house.set house.toJSON()
    ok eventsTriggered is 0, "No add / remove events were triggered"

  test "triggers appropriate add / remove / change events on bulk assignment", ->
    house = new House(
      id: "house-100"
      location: "in the middle of the street"
      occupants: [
        id: "person-5"
        nickname: "Jane"
      ,
        id: "person-6"
      ,
        id: "person-8"
        nickname: "Jon"
      ]
    )
    addEventsTriggered = 0
    removeEventsTriggered = 0
    changeEventsTriggered = 0
    
    #.bind( 'all', function(ev, model) {
    #          console.log('all', ev, model);
    #          })
    house.bind("add:occupants", (model) ->
      ok model.id is "person-7", "Only person-7 should be added: " + model.id + " being added"
      addEventsTriggered++
    ).bind "remove:occupants", (model) ->
      ok model.id is "person-6", "Only person-6 should be removed: " + model.id + " being removed"
      removeEventsTriggered++

    nicknameUpdated = false
    house.get("occupants").bind "change:nickname", (model) ->
      ok model.id is "person-8", "Only person-8 should have it's nickname updated: " + model.id + " nickname updated"
      changeEventsTriggered++

    house.set occupants: [
      id: "person-5"
      nickname: "Jane"
    ,
      id: "person-7"
    ,
      id: "person-8"
      nickname: "Phil"
    ]
    ok addEventsTriggered is 1, "Exactly one add event was triggered (triggered " + addEventsTriggered + " events)"
    ok removeEventsTriggered is 1, "Exactly one remove event was triggered (triggered " + removeEventsTriggered + " events)"
    ok changeEventsTriggered is 1, "Exactly one change event was triggered (triggered " + changeEventsTriggered + " events)"

