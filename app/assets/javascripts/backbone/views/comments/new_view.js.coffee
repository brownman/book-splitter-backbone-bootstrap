RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.NewView extends Backbone.View
  template: JST["backbone/templates/comments/new"]

  events:
    "keypress .content": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    if e.keyCode == 13 and @$('.content').val() != ''
      @model.unset("errors")
      @model.set('content', @$('.content').val())

      @collection.create(@model.toJSON(),
        success: (comment) =>

          view = new RailsBackboneRelational.Views.Comments.CommentView({model : comment})
          tmp =  view.render().el
          #tmp0 = $(@.el).parent().parent().attr("id");

          tmp1 = $(@.el).parent().parent().find('.comments-list')
            #.attr("class");


          #alert('id: ' + tmp0)
          #alert('class: ' + tmp1)
          #console.log(tmp0.class)

          tmp2 = $(@.el).parent().prev().find('.comments-list')
          console.log(tmp2)
          $(tmp1).append(tmp)

          # $("#posts-list").prepend(view.render().el)
          @$('.content').val('good')

        error: (comment, jqXHR) =>
          alert('error')
          @model.set({errors: $.parseJSON(jqXHR.responseText)})
      )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    return this
