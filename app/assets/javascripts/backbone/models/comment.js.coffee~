class RailsBackboneRelational.Models.Comment extends Backbone.RelationalModel
  paramRoot: 'comment'

  @array = []
  defaults:
    content: null
    direction: true
    title: null
  
  initialize: () -> 
    tmp = @get('content')
    if (tmp && tmp.length > 0)         
      @array =  @split()

    obj = { counter: 0 }
    _.extend(obj,Backbone.Events)
    obj.on('event',
           () ->  obj.counter += 1 
          )
    obj.trigger('event')
    @equal1(obj.counter,1,'counter should be incremented.')
    obj.trigger('event')
    obj.trigger('event')
    obj.trigger('event')
    obj.trigger('event')
    @equal1(obj.counter, 5, 'counter should be incremented five times.')
    #console.log(this)
    #alert('brothers:')
    #save: ->
    #alert('save')
    
  equal1: (a,b,c) ->
    #alert(a + '|' + '|' +c)

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
    #    story_enc =  story_enc.replace(/\n/g, "^")
    arr_symbols = [',', '!', '.', "?", ":", ";", "=", "\n" ]
    story_enc = @replace(story_enc, arr_symbols)
    story_arr = story_enc.split('$')
    story_arr

  toJSON1 : () ->
    json = _.clone(this.attributes);
    console.log(json)
    json
    
    #validate: () ->
     
class RailsBackboneRelational.Collections.CommentsCollection extends Backbone.Collection
  model: RailsBackboneRelational.Models.Comment
  url: '/comments'
  #@num = 0

  initialize: () ->

    #console.log(this)
    this.bind("add", @add_ofer)
    #@num = this.models.length
    #console.log(options)

    #for model in this.models.array

      
     
  add_ofer: () =>
    console.log(this)
    length_i = this.models.length
    length_j = this.models[0].array.length
  
    #find min array
    min = length_j
    for i in [0...length_i] 
      #console.log(this.models[i].array)
      tmp = this.models[i].array.length
      #console.log(i + ' ) ' + tmp)
      min = if (min < tmp) then min else tmp

    #console.log('min is: ' + min)
    for j in [0...length_j]
      num1 = 0
      for i in [0...length_i]
        num1 += if (this.models[i].array[j] == '=') then 1 else 0 
      if ( num1 == length_i)
        for i in [0...length_i]
          this.models[i].array[j..j] = [] 
          

    

  #alert('add_ofer triggered')
  #localStorage: new Backbone.LocalStorage("CommentsCollection")
