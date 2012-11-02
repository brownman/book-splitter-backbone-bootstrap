describe "MyGame", ->
   beforeEach ->
     @comment = new RailsBackboneRelational.Models.Comment({content: 'a,b,c'})

   it "should have two players", ->
      expect(@comment.array).toEqual ['a,','b,','c'] 
      
