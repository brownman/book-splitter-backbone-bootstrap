RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.NewView extends Backbone.View
  template: JST["backbone/templates/comments/new"]

  events:
    "submit .field1": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    #e.keyCode == 13 and
    if @$('.content').val() != ''
      @model.unset("errors")
      @model.set('content', @$('.content').val())
      @model.set('title', @$('.title').val())
      @model.set('direction', false)
      @collection.create(@model.toJSON(),
        success: (comment) =>
          alert('success')
          view = new RailsBackboneRelational.Views.Comments.CommentView({model : comment})
          tmp =  view.render().el
          tmp1 = $(@.el).parent().parent().find('.comments-list')
          $(tmp1).append(tmp)
          @$('.content').val('good')
          @$('.title').val('good1')

        error: (comment, jqXHR) =>
          alert('error')
          console.log(comment)
          @model.set({errors: $.parseJSON(jqXHR.responseText)})
      )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    return this
