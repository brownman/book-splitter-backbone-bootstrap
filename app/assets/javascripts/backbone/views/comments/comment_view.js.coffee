RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    "click .destroy" : "destroy"
    "click .todo-array button": "show_index"

  initialize: () ->
    this.model.bind('change', this.render);


  className: "span4"
  tagName: "td"



  destroy: () ->
    @model.destroy()
    this.remove()

    return false

#,csrender: function() {
      #var listed = this.splitted()
    #this.$el.html(this.template({ list: listed, task: this.model }));
    #return this;

  render: =>

    listed2 = this.splitted2()
    
    comment = @model #.toJSON()
    tmp = @template(
      'comment':comment
      'listed2': listed2
    )
    
    $(@el).html(tmp)
    return this
  
  splitted: ->
    str = @model.split()
    list = "<% _.each(people, function(name) { %> <li><%= name %></li> <% }); %>";
    arr = _.template(list, {people : str});
    #console.log(arr)
    arr
 
  splitted2: ->
    str = @model.split()
    list = "<% _.each(people, function(name) { %> <button class='btn  btn-info btn-block CodeMirror-wrap test'><%= name %></button> <% }); %>";
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
        
