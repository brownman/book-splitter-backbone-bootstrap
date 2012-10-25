class RailsBackboneRelational.Models.Comment extends Backbone.RelationalModel
  paramRoot: 'comment'

  defaults:
    content: null
    done: false
  
  #initialize: () -> 
    #console.log(this)
    #alert('brothers:')
    #save: ->
    #alert('save')
    

  replace : (str, sym) -> 
    for item in sym
     str = @replace_one(str, item)
    str
             
  replace_one : (story,sign) ->
    to_sign = sign + "$"
    from="[" + sign  + "]"
    from_reg = new RegExp(from,"g")
    str = story.replace(from_reg , to_sign)
    str
    

  split : () ->
    str = @get('content')
    story_enc = str 
    story_enc =  story_enc.replace(/\n/g, " ")
    arr_symbols = [',', '!', '.', "?", ":", ";", "=" ]
    story_enc = @replace(story_enc, arr_symbols)
    story_arr = story_enc.split('$')
    story_arr

  #toJSON : () ->
    #json = _.clone(this.attributes);
    #json
    
class RailsBackboneRelational.Collections.CommentsCollection extends Backbone.Collection
  model: RailsBackboneRelational.Models.Comment
  url: '/comments'
  #localStorage: new Backbone.LocalStorage("CommentsCollection")
