

  describe "sound spec", ->
    beforeEach ->

      Timing = RailsBackboneRelational.Modules.Timing
      @s1= new Timing()
      console.log @s1

    it "should create instance of Module Sound", ->
      expect(typeof @s1).toEqual 'object'
      expect(@s1.constructor.name).toEqual 'Timing'

 
      #expect(@comment.errors).toEqual false
    it "should set empty array by givven array", ->
      #arr1 = ['a','b','c']
      @s1.generate_array(3)
      
      expect(@s1.arr).toEqual [undefined,undefined,undefined]     
      expect(@s1.arr.length).toEqual 3


        
    it "should be able to calculate time by given values", ->
      arr1 = [1,undefined,undefined,4]
     # first = @s1.first_empty(arr1)
      #expect(first).toEqual 1

    it "kk", ->
      arr1 = [] 
      arr2 = [1,2,3,4]
      res =  @s1.set_time(arr1)
      #expect(arr2).toEqual(res)

      #arr2 = @s1.generate_array(arr1)
      #expect(arr2.length).toEqual 3
      #expect(arr2).toEqual [undefined,undefined,undefined]
      #expect(@comment.errors).toEqual false
  
     it "should fill the range of 2 numbers and fill an array", ->
     # arr1 = [1,undefined,undefined,4]
      size = 3 
      min = 0
      max = 10
      arr = @s1.create_arr_of_gap(min,max,size)
      expect(arr).toEqual([2.5,5,7.5])
      #expect(@comment.errors).toEqual false
        #expect(@comment.errors).toEqual false

     it "should find first undefined in array", ->
     # arr1 = [1,undefined,undefined,4]
        arr = [1,undefined, undefined, 2]
        index = _.indexOf(arr, undefined)
        expect(index).toEqual(1)

     it "should group undefined in array", ->
        arr = [1,undefined, undefined, 2]
       
       # for i in [0...arr.length]
       #   if arr[i] == undefined
        t_arr = []
        stack = 0
        for i in [0...arr.length]
          if(arr[i] != undefined)
            if stack !=0
              n_arr = []
              n_arr.push stack
              t_arr.push(n_arr) 
              stack = 0
            t_arr.push arr[i]
          else 
            stack += 1


        expect(t_arr).toEqual([1,[2],2])

      it "should calculate values of sub-arrays"
        #if arr[i] is type Array:
        #find min, max ,length  
        #than replace arr[i] with calculated array

