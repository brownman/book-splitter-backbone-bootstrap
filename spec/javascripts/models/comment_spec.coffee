describe "comment model", ->
   beforeEach ->
     @comment = new RailsBackboneRelational.Models.Comment({title: ''})

   it "should have two players", ->
      expect(@comment.isValid()).toEqual false
      #expect(@comment.errors).toEqual false
      
