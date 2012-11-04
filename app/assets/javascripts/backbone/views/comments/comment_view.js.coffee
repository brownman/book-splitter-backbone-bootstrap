RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]
 
  
  @status = 'saved'

  events:
    "click .destroy" : "destroy"
    "dblclick .todo-array button": "show_index"

    "click .todo-array button": "whiteSpaceCheck"

    "click .direction"              : "toggleDone" 
    "click .save"              : "save_array" 
    
    #"hover .todo-array button": "show_tooltip"

  initialize: () ->
    
    @status = 'false'

    #@update_status(false)
    
    @status = 'saved!'
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
    tmp = @template(
      'obj': comment
      'listed2': listed2
      'obj2': status
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
   
        
  show_index:   (ev) -> 
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


  save_array: () ->  
    text = @get_array().join("")
    @model.save( 
     content: text 
    )
    
  whiteSpaceCheck:   (ev) -> 
    item =  $(ev.target)
    str = item.context.innerText
    
    if(str != '=')
     $(item).toggleClass("test1");
     num =(item).index()
    else
     @show_index(ev)
    
   


        
