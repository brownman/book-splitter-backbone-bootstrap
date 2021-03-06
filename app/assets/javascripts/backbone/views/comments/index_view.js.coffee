RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.IndexView extends Backbone.View
  template: JST["backbone/templates/comments/index"]

  #events:
  #      "hover .comments-list button" : "show_indexes"

  className: 'span12'
  tagName: 'div' 
  events:
    "click .update_spans" : 'decrease_span'
    
  decrease_span: () ->
    console.log('another callback by parent')

  initialize: () ->
    #alert('options: ' + @options.ofer_length)
    @num = @options.comments.length
    #ofer_length
    #@options.comments.each(@update_span(num))
    #.on('add2', this.alert_parent);
    
    #@options.comments.bind('reset', @addAll)

    @options.comments.bind('add2', @add2_view)

    #@el.delegateEvents(events);
    #@options.comments.bind('remove', @addAll)
    #@options.comments.bind('add', @addModelCallback);

    #@options.comments.bind('remove', @addModelCallback);

  #update_span: (num) =>
    #alert(num)


  #show_indexes: (ev) ->
    #num = $(ev.target).index()
    #$()
    #alert(num)
  add2_view: () =>
    console.log(this)
    console.log('add2_view')
    #this.remove()
    #this.addAll()
    #this.render()
    #
    #@$(".comments-list").html('<a>ZVV</a>')
   
    tmp = @render()
    view =  @el

    #view.append(tmp) 
    view = tmp
   
    #@$el.show()

    #@el.html(tmp)
    
  addModelCallback1: () =>
    console.log(this)
    #alert('collection callback')
    #
    console.log('collection callback')

    #@$(".comments-list").html('')
    #tmp = @render()

    #$(@el).html(tmp)

   
  alert_parent: () ->
    console.log(this)
    alert('parent')

  addAll: () =>

    
    #console.log(@options.comments)
    comments1 = @options.comments
    comments1.each(@addOne)
    @num = @container.length 



    #@container.each()

    #@container.call(this.update_span());

    @container.each(@show_one)

  addOne: (comment ) =>
   #this.trigger('somethingHappened')
    if(comment.hide1 == true) 
      console.log('dont show me.')
      return

    abcd = 
      model : comment
      c_length: @num.toString()


    
    view = new RailsBackboneRelational.Views.Comments.CommentView(abcd)



    view.on('hide1', @update_spans1 )
    #view.$el.on('click .hide1', @update_spans1 )
    #view.el.className =  
    #view.update_span(@num)

    @container.add(view)
    #view.model.collection.each(@update_span)


  show_one: (view) =>
    view.update_span(@num)
    @$(".comments-list").append(view.render().el)

  updateOneSpan: () => 
    view.update_span(@num)
    

    
  render: ->
    comments = @options.comments.toJSON() 

    #@num = @options.comments.length 

    obj = 
      comments: comments
      #num: @num
    console.log('Comments_collection: '  + obj)

    $(@el).html(@template())
    #$(@el).html(@template(obj))
    #
    @container = new Backbone.ChildViewContainer()
    @addAll()

    return this

  update_spans1: () =>
    console.log('how many viewable ? ')
    #@num -= 1
    #alert(@num)
    #comments1 = @options.comments
    #comments1.each(@updateOneSpan)
    @render()



