
String::dasherize = ->
  this.replace /_/g, "-"
  
String::senitize = ->
  this.replace /_/g, "-"
#alert "one_two".dasherize()

class RailsBackboneRelational.Models.Post extends Backbone.RelationalModel
  paramRoot: 'post'

  defaults:
    title: 'title?'

  relations: [
    type: Backbone.HasMany
    key: 'comments'
    relatedModel: 'RailsBackboneRelational.Models.Comment'
    collectionType: 'RailsBackboneRelational.Collections.CommentsCollection'
    includeInJSON: false
    reverseRelation:
      key: 'post_id',
      includeInJSON: 'id'
  ]
  
  validate: (attrs) -> 
    if (attrs.hasOwnProperty('title') && _.isNull(attrs.title)) 
      return 'attr.direction must be a non null value.' 
            
        

  sanitize1: (str) -> 
    str.senitize()
        
        
  initialize: () ->
    console.log('init post') 
  

    

class RailsBackboneRelational.Collections.PostsCollection extends Backbone.Collection
  model: RailsBackboneRelational.Models.Post
  url: '/posts'

  initialize: () ->
    #console.log('init post')

    #alert('new collection posts')
  #localStorage: new Backbone.LocalStorage("PostsCollection")
  comparator: (post) ->
    return post.get('id');
