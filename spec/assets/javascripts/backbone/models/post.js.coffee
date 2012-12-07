
describe "post model", ->
  beforeEach ->
    @post = new RailsBackboneRelational.Models.Post({content: 'a,b,c'})
    @comments = @post.get('comments')

  it "should have a post model", ->
    expect(@post).toBeDefined()
    #Equal ['a,','b,','c']

  it "should have 1 comment", ->
    expect(@comments.length).toEqual(3)
    #@post.add({title: ''})
    #expect(@comments.length).toEqual(1)


