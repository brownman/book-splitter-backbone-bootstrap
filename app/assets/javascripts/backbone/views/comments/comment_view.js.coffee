RailsBackboneRelational.Views.Comments ||= {}

class RailsBackboneRelational.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]
 
  
  this.log = _.bind(alert, console);


  events:
    "click .destroy" : "destroy"

    "click .mode" : "switch_mode"
    #"dblclick .todo-array button": "push_index"

    "click .all .todo-array button": "whiteSpaceCheck"

    "click .direction"              : "set_direction" 

    "click .hide1"              : "toggleShow" 
    "click .save"              : "save_array" 
    

    "click .Load"              : "Load" 
    "click .Play"              : "Play" 
    "click .Stop"              : "Stop" 
    "click .Pause"              : "Pause" 

    "blur .seconds"              : "set_delay" 

    "blur .speed"              : "set_speed" 

    "blur .order"              : "set_order" 

    "blur .content"              : "set_content" 

    "blur .title"      : "set_title"

    "blur .url_sound"      : "set_url_sound"
  
    
  switch_mode: (e) ->
    @play_mode=   !@play_mode

    @render()

    a = $(@el).find('.all')
    if(!@play_mode)
      a.css("background-color","#ffbb88");
    
    
  set_speed: (e) ->
   #console.log(e)
      input = e.target.value

        #this.$(".content");
      console.log(input)

      #@model.save({ content: input })
      #
      @speed = input
      @voice.playbackRate =parseFloat(input) 
      


  set_url_sound: (e) ->
    console.log('sound')



    input = e.target.value

    #@voice.src =      input.toString() 

      #'http://koebu.s3.amazonaws.com/mp3/c/c7/c78a/c78a5fe8acbd284852a3b1918e9f9772e59868b2.mp3'

      #'http://k003.kiwi6.com/hotlink/3dgmyavs49/your_name_ft_gaduk.mp3'



    #console.log(input)



    #sound = new Audia(
                  #src: input
                  #loop: false 
                  #)

    #sound.src = 'http://k003.kiwi6.com/hotlink/3dgmyavs49/your_name_ft_gaduk.mp3'
    #sound.play()
    @model.save({url_sound: input})

      


    
   




  Stop: (e) ->
        #e.preventDefault() 
        if(!@voice.ended) 
          @voice.pause() 
          @voice.currentTime = 0 
          #$(this).unbind('touchstart');
  Play: (e) ->
        #e.preventDefault() 

        @voice.play() 
        @voice.playbackRate = 1 

        @voice.removeEventListener('timeupdate',     @onTimeUpdate, this) 
        @voice.addEventListener('timeupdate',     @onTimeUpdate, this) 
        a = $(@el).find('.Stop')
        $(a).removeAttr("disabled")
        a = $(@el).find('.Pause')
        $(a).removeAttr("disabled")
     #$(this).unbind('touchstart');
               
  Pause: (e) ->
        #e.preventDefault() 
        @voice.pause() 

    
  onTimeUpdate: ( ) =>
        #p = @voice
        currTime = @voice.currentTime 
        #console.log(currTime)
        val       = parseInt(currTime) 
        #str = parseInt(currTime/60,10) +':' +
         #parseInt(currTime%60,10) + '/' + 
         #parseInt(p.duration/60,10) +':' +
         #parseInt(p.duration%60,10) 
          #.toString()
        #console.log(str)

        #str1 = parseInt(p.duration / 60 ,10) 
        
        $(@el).find('.sound_timer').attr('value',val.toString())

         
      

        #@el.$('.sound_time').textContent=str
            #
            #attr('value', val)
            #
            #


        #$(item).attr('value', 'not Saved');

   #p.audio = new Audio('http://k003.kiwi6.com/hotlink/3dgmyavs49/your_name_ft_gaduk.mp3');


    #"hover .todo-array button": "show_tooltip"

        

  set_content: (e) ->
      console.log(e)
      input = e.target.value

        #this.$(".content");
      console.log(input)

      @model.save({ content: input })
      #@render()


  set_title: (e) ->
    
    #this.trigger('somethingHappened')
    #if e.keyCode is 13
      console.log(e)
      input = this.$(".title");
      console.log(input)

      @model.save({ title: input.val() })
      
    #$(@el).removeClass("editing")
  initialize: () ->
   @play_mode = true



   
   console.log(this)

   console.log(@options)
   #num =  @options['c_length']
   #@update_span(num)
   #@options.c_length
   @status = 'saved'
   @seconds = 30

   @speed = 1
   #@hide1 = false
   this.model.bind('change', this.before_render);

   $(@el).find('.Stop').attr('disabled','disabled')

   $(@el).find('.Pause').attr('disabled','disabled')
   $(@el).find('.Play').attr('disabled','disabled')


  Load: () ->
   @voice = new Audio()

   @voice.autoplay = false 
   @voice.defaultPlaybackRate = 1 

   str =  @model.get('url_sound')
   console.log('load file: ' + str)

   @voice.src =     str 

   @voice.removeEventListener("canplaythrough", @alert_status, this)
   @voice.addEventListener("canplaythrough", @alert_status, this)

   @voice.load() 





  alert_status: () =>
    #alert('can play')
    a = $(@el).find('.Play')
    $(a).removeAttr("disabled")

 
  before_render:() =>
    @status = 'saved'
    @render()
  
    
  get_array: () ->
    @model.array

  className: 'sspann'

  tagName: "td"

  set_direction : () ->
    @model.save(
      {direction : !this.model.get('direction') }
      {silent: true}
    )
    @render()



  destroy: () ->
    @model.destroy()
    this.remove()

    return false



  render: ->

    listed2 = this.splitted2()
    
    comment = @model.toJSON()

    status = @status.toString()
    seconds = @seconds.toString()

    spans = @el.className.toString()
    order = comment.order
   
    console.log(comment)
    tmp = @template(
      'obj': comment
      'listed2': listed2
      'obj2': status
      'obj3': seconds


      'obj4': spans 
      'obj5': order 

      'obj6': @hide1 

      'play_mode': @play_mode
      'speed': @speed

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
    if(@play_mode)
      item =  $(ev.target)
      num =(item).index()
      array =    @get_array()
      array[num...num] = ['=']
      @array = array
    #@update_status('true')
      @status = 'not saved!'
    else
      item =  $(ev.target)
      num =(item).index()
      array =    @get_array()
      a = parseFloat(@voice.currentTime)
      array[num] = a.toString()


      
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
    #this.trigger('somethingHappened');
    #@render
    

  
  whiteSpaceCheck:   (ev) -> 
    

    item =  ev.target
    str = $(item).context.innerText
    if(@play_mode)
      tmp1 =  $(item).hasClass("test1") 
      #alert(tmp1)
      if(str != '=' && !tmp1)
         _.delay(_.bind(this.something, item), @seconds * 1000 , 'logged later') 
         $(item).addClass("test1") 
      else
         @push_index(ev)
    else
         @push_index(ev)
      
    ev.stopImmediatePropagation()
    #return false
  
  something: (msg) ->
     $(this).removeClass("test1") 
  
  set_delay: (ev) ->
    @seconds = ev.target.value
    console.log(@seconds) 
   

  set_order: (ev) ->
    order1 = ev.target.value
    console.log(order1) 
    num = parseInt(order1, 10)
    @model.save({ order: num })

  toggleShow : () ->
    @model.hide1 = !@model.hide1
    #@remove() 
    @trigger('hide1') 

  update_span: (num) ->
    #num = @col_get_length()
     #alert(num)
     #@update_span(num)
    inta = parseInt(12/num)
    str = "span" + inta
    console.log(this)
    @el.className = str 
  






