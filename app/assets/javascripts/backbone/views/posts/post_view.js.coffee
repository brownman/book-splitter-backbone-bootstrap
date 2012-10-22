RailsBackboneRelational.Views.Posts ||= {}

class RailsBackboneRelational.Views.Posts.PostView extends Backbone.View
  template: JST["backbone/templates/posts/post"]

  events:
    "click .destroy" : "destroy"

  initialize: () ->
    #alert('init post')
    #alert((@model.get('comments')).length)

  className: "accordion-group"

  tagName: "div"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    num = @model.get('comments').length
    post = @model.toJSON()
    #alert(num)
    tmp = @template(
      'post': post
      #'length':    num 
    )
    $(@el).html(tmp)
    return this

  render2: =>

    listed2 = this.splitted2()
    
    comment = @model #.toJSON()
    tmp = @template(
      'comment':comment
      'listed2': listed2
    )
    
    $(@el).html(tmp)
    return this
