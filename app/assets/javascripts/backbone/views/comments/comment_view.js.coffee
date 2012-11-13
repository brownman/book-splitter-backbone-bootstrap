RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]
 
  
  this.log = _.bind(alert, console);


  events:
    "click .destroy" : "destroy"
    "dblclick .todo-array button": "push_index"

    "click .todo-array button": "whiteSpaceCheck"

    "click .direction"              : "toggleDone" 
    "click .save"              : "save_array" 

    "blur .seconds"              : "set_delay" 


    
    #"hover .todo-array button": "show_tooltip"

  initialize: () =>


   console.log(this)

   console.log(@options)
   num = @options['c_length']
     #this.model.collection.length
   @update_span(num)
   #@options.c_length
   @status = 'saved'
   @seconds = 10
   this.model.bind('change', this.before_render);
 
  before_render:() =>
    @status = 'saved'
    @render()
  
    
  get_array: () ->
    @model.array

  className: 'sspann'

  tagName: "td"

  toggleDone : () ->
    @model.save(
    
      direction : !this.model.get('direction')
    )


    

  destroy: () ->
    @model.destroy()
    this.remove()

    return false



  render: =>
    listed2 = this.splitted2()
    
    comment = @model.toJSON()
    status = @status.toString()
    seconds = @seconds.toString()
    spans = @el.className.toString()
   
    console.log(comment)
    tmp = @template(
      'obj': comment
      'listed2': listed2
      'obj2': status
      'obj3': seconds

      'obj4': spans 
    )
    $(@el).html(tmp)
    
    return this
  
 
  splitted2: ->
    arr0 = @get_array()
    list = "<% _.each(people, function(name) { %> <button class='btn  btn-info btn-block test'><%= name %></button> <% }); %>";
    arr = _.template(list, {people : arr0});
    #console.log(arr)
    arr
 
  show_tooltip: (ev) ->
    num = $(ev.target).index()
    #$(@el).popover({title: 'im the title'})
    alert(num)
   
        
  push_index:   (ev) -> 
    item =  $(ev.target)
    num =(item).index()
    array =    @get_array()
    array[num...num] = ['=']
    @array = array
    #@update_status('true')
    @status = 'not saved!'
    @render()
  
  update_status2: (sign) ->
    item = @$('.save')
    console.log(item)
    if(sign)
     $(item).attr('value', 'not Saved');
    else
     
     $(item).attr('background', '#000fff');
     $(item).attr('value', 'Saved');
  
  update_span: (num) ->
    inta = parseInt(12/num)
    str = "span" + inta
    console.log(this)
    @el.className = str 


  save_array: () ->  
    text = @get_array().join("")
    @model.save( 
     content: text 
    )
    this.trigger('somethingHappened');
    

  
  whiteSpaceCheck:   (ev) -> 
    item =  ev.target
    str = $(item).context.innerText
    if(str != '=')
     _.delay(_.bind(this.something, item), @seconds * 1000 , 'logged later') 
     $(item).toggleClass("test1") 
    else
     @push_index(ev)
  
  something: (msg) ->
     $(this).toggleClass("test1") 
  
  set_delay: (ev) ->
    @seconds = ev.target.value
    console.log(@seconds) 
   


        
