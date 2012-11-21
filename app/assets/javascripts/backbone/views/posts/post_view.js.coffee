RailsBackboneRelational.Views.Posts ||= {}

class RailsBackboneRelational.Views.Posts.PostView extends Backbone.View
  template: JST["backbone/templates/posts/post"]

  events:
    "click .destroy" : "destroy"
    #"click .submit" : "update"
    #"dblclick a.todo-content" : "edit",

    "blur .title"      : "set_title"
    "click .accordion-toggle .open"      : "show_post"



  initialize: () ->
    #alert('init post')
    #alert((@model.get('comments')).length)
    
    #this.on('somethingHappened', this.alert_parent );
    #this.trigger('somethingHappened')

  className: "accordion-group"

  tagName: "div"

  show_post: () -> #fetch and show
    console.log(this)
    tmp = this.render()

    post = @model
    comments1 = post.get('comments')
    comments1.each(@reset_hide1) 
    num = comments1.length
    view = tmp 
    console.log(view)
    abc = 
      comments: comments1
      ofer_length: num
      hide1: false

    comments_view = new RailsBackboneRelational.Views.Comments.IndexView(abc) 
    view.$(".comments").html(comments_view.render().el)
    new_comment_view = new RailsBackboneRelational.Views.Comments.NewView(collection: comments1)
    view.$(".new_comment").html(new_comment_view.render().el)
  reset_hide1: (comment) =>
    comment.reset_hide1()

    
  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  #update: ->
     
     #this.model.save(
      #title: tmp 
    #)
    #
    #
  set_title: (e) ->

    #this.trigger('somethingHappened')
      console.log(e)
      @input = this.$(".title");
      console.log(@input)

      @model.save({ title: @input.val() })
    #$(@el).removeClass("editing")

  render: ->

           
    post = @model.toJSON()
    console.log(this)
    num = @model.get('comments').length 
    #alert(num)
    tmp = @template(
      'post': post
      'length':    num 
    )
    $(@el).html(tmp)

    #$(@el).html(@template())
    #view =   $(@el)

    #comments1 = @model.get('comments')
    #new_comment_view = new RailsBackboneRelational.Views.Comments.NewView(collection: comments1)
    #view.find(".new_comment").html(new_comment_view.render().el)

    return this

  not_render2: =>

    listed2 = this.splitted2()
    
    comment = @model #.toJSON()
    tmp = @template(
      'comment':comment
      'listed2': listed2
    )
    
    $(@el).html(tmp)
    return this
