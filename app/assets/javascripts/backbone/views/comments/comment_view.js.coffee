RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    "click .destroy" : "destroy"
    "click .todo-array li": "show_index"

  initialize: () ->
    this.model.bind('change', this.render);


  tagName: "td"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: =>
    #alert('render comment!')
    #console.log(@model.get('content'))
    #alert(@model.get('content')) 
    list0 = @model.toJSON()
    
    #console.log(list0)
    tmp = @template(list0)
    
    #console.log(tmp)
    $(@el).html(tmp)
    return this
  
  splitted: ->
    str = @model.split()
    list = "<% _.each(people, function(name) { %> <li><%= name %></li> <% }); %>";
    arr = _.template(list, {people : str});
    #console.log(arr)
    arr
 
        
  show_index:   (ev) ->  
    num = $(ev.target).index()
    #alert(num)
    array =     @model.split()
    array[num...num] = ['=']
    text = array.join("")
    @model.save( 
     content: text 
    )
        
