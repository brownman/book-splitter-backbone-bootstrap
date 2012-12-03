

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

 
      #expect(@comment.errors).toEqual false
        #expect(@comment.errors).toEqual false
    it "should be able to calculate time by given values", ->
      arr1 = [1,2,undefined,10]
      #arr2 = @s1.generate_array(arr1)
      #expect(arr2.length).toEqual 3
      #expect(arr2).toEqual [undefined,undefined,undefined]
      #expect(@comment.errors).toEqual false
  