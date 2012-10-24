RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.IndexView extends Backbone.View
  template: JST["backbone/templates/comments/index"]

  #events:
  #      "hover .comments-list button" : "show_indexes"

  className: 'span12'
  tagName: 'div' 
  
  initialize: () ->
    #alert('options: ' + @options.ofer_length)
    @num = @options.ofer_length
    #@options.comments.each(@update_span(num))
    
    @options.comments.bind('reset', @addAll)

  #update_span: (num) =>
    #alert(num)


  #show_indexes: (ev) ->
    #num = $(ev.target).index()
    #$()
    #alert(num)
    

  addAll: () =>
    @options.comments.each(@addOne)

  addOne: (comment) =>
    abcd = 
      model : comment
    view = new RailsBackboneRelational.Views.Comments.CommentView(abcd)

    inta = parseInt(12/@num)
    view.el.className = "span" + inta

    @$(".comments-list").append(view.render().el)

  render: =>
    $(@el).html(@template(comments: @options.comments.toJSON() ))
    @addAll()

    return this
