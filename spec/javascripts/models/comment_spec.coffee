describe "comment model", ->
  beforeEach ->
    @comment = new RailsBackboneRelational.Models.Comment({title: 'i'})

  it "should have two players", ->
    expect(@comment.isValid()).toEqual true
    #expect(@comment.errors).toEqual false
