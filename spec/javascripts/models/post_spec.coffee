describe "post model", ->
   beforeEach ->
     @post = new RailsBackboneRelational.Models.Post({content: 'a,b,c'})

   it "should have a post model", ->
     #expect(@post.isValid()).toEqual ['a,','b,','c'] 
      
      
