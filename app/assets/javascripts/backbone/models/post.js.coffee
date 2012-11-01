class RailsBackboneRelational.Models.Post extends Backbone.RelationalModel
  paramRoot: 'post'

  defaults:
    title: null

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

class RailsBackboneRelational.Collections.PostsCollection extends Backbone.Collection
  model: RailsBackboneRelational.Models.Post
  url: '/posts'

  initialize: () ->
    #console.log('init post')

    #alert('new collection posts')
  #localStorage: new Backbone.LocalStorage("PostsCollection")
