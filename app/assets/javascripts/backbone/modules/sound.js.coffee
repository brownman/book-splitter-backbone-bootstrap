 


class RailsBackboneRelational.Modules.Timing #extends Backbone.RelationalModel

    constructor: (@name, @arr) ->
    	console.log @
    	@arr = []

    # Prototype method
    download: (episode) ->
        console.log 'Downloading ' + episode + ' of ' + @name

    # Static method
    @play: (episode, name) ->
        console.log 'Playing ' + episode + ' of ' + name         

    playOn: ->
        console.log 'unknown'   

    generate_array: (num) ->
        @arr = new Array(num)
        #console.log 'unknown'  

    set_time: (arr) ->
    	[1,2,4]
        #console.log 'unknown' 
    first_empty: (arr) ->
        first = arr.first(undefined)

    

    create_arr_of_gap: (ar1) ->
      min = ar1[0]
      size = ar1[1]
      max = ar1[2]

      jump = (max-min)/(size+1)
      arr = _.range(min, max, jump);
      arr = _.rest(arr)
      arr

    group_undefineds: (arr) ->
        t_arr = []
        stack = 0
        end = (arr.length-1) 
        for i in [0..end]
          if(arr[i] != undefined)
            if stack !=0
              #n_arr = []
              end = arr[i]
              n_arr =  [ start ,stack, end ] #avoid array overflow

              t_arr.push(n_arr) 
              stack = 0
              start = 0
            t_arr.push arr[i]
          else 
            if stack == 0
               start = arr[i-1]
            stack += 1
        t_arr
  
    replace_groups: (arr) ->
        return 1