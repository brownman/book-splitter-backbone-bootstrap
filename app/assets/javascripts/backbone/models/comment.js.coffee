class RailsBackboneRelational.Models.Comment extends Backbone.RelationalModel
  paramRoot: 'comment'

  @array = []
  @hide1 = false
  
  defaults:
    content: 'content'
    direction: true
    title: 'title' 
    order: 0 
  
  validate: (attrs) ->

    if (attrs.title == '')  
      return "title is empty"
    
    if (attrs.content == '')  
      return "content is empty"
    
  initialize: () -> 
    @hide1 = false
    this.on('change:content', @update_array)

    #this.on('change:direction', @update_hide)

    @update_array()
    #console.log(this)
    #save: ->
    
  #update_hide: () =>
   #alert('update hide')
      
  update_array: () =>
   #alert('update array')
   tmp = @get('content')
   if (tmp && tmp.length > 0)         
      @array =  @split()

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
    story_enc =  story_enc.replace(/\n/g, "^")
    
    arr_symbols = [',', '!', '.', "?", ":", ";", "=" ]
    #if !@direction
      #arr_symbols.push  "\n"
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
 

 
  length1: () ->
   num =     this.length - @hides
   num

  initialize: () ->

    @hides =  0
    #this.bind('add', @addModelCallback);
    #console.log(this)
    #
    

    this.bind("add remove", @add1)


    this.bind("change:order", @sort1)





    this

    #this.bind("reset", @sort1)
    
    #this.bind("change", @change_ofer)

    #this.bind("add", @render)
    #@num = this.models.length
    #console.log(options)

    #for model in this.models.array



       
  sort1: () =>
   console.log('sort1')
   alert('sort1')
   this.sort()

   this.trigger('add2')

  add1: () =>
   #this.sort()
   console.log(this)
   length_i = this.models.length
   if length_i > 0
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


   this.sort()


   this.trigger('add2')
          

  comparator: (comment) ->
    #return comment.get('id') 

    return comment.get('order') 

  decrease: () ->
    @hides += 1
    @trigger('update_spans')

  #localStorage: new Backbone.LocalStorage("CommentsCollection")
