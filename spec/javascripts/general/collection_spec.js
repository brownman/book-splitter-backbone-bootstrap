describe('About Backbone.Collection', function() {
    it('Can add Model instances as objects one at a time, or as arrays of models.', function() {
       window.TodoList = 
        
window.TodoList =  RailsBackboneRelational.Collections.PostsCollection
        
        var todos = new TodoList();
        
        expect(todos.length).toBe(0);
        
        todos.add({ title: 'Clean the kitchen' });
        
        expect(todos.length).toEqual(1);
        
        // How would you add multiple models to the collection with a single method call?
              
        todos.add([{ title: 'Do the laundry'},
                   { title: 'Clean the house'}]);
        expect(todos.length).toEqual(3);
    });
    
    it('Can have a comparator function to keep the collection sorted.', function() {
        var todos = new TodoList();
        
        // Without changing the sequence of the Todo objects in the array, how would you
        // get the expectations below to pass?
        //
        // How is the collection sorting the models when they are added? (see TodoList.comparator in js/todos.js)
        //
        // Hint: Could you change attribute values on the todos themselves?
        
        todos.add([{ title: 'Do the laundry'},
                   { title: 'Clean the house'},
                   { title: 'Take a nap'}]);
        
       // expect(todos.at(1).get('title')).toEqual('Clean the house');
       // expect(todos.at(2).get('title')).toEqual('Do the laundry');
       // expect(todos.at(0).get('title')).toEqual('Take a nap');
    });
    
    // How are you supposed to know what Backbone objects trigger events? To the docs!
    // http://documentcloud.github.com/backbone/#FAQ-events
    
    it('Fires custom named events when the contents of the collection change.', function() {
        var todos = new TodoList();
        
        var addModelCallback = jasmine.createSpy('-add model callback-');
        todos.bind('add', addModelCallback);
        
        // How would you get both expectations to pass with a single method call?
       
       todos.add([                   { title: 'Clean the house'}
                   ]);

        expect(todos.length).toEqual(1);
        expect(addModelCallback).toHaveBeenCalled();
        
        var removeModelCallback = jasmine.createSpy('-remove model callback-');

        todos.bind('remove', removeModelCallback);

        todos.models[0].destroy()
        /*
         *todos.remove({index: 1})
         */
        // How would you get both expectations to pass with a single method call?
        
        expect(todos.length).toEqual(0);
        expect(removeModelCallback).toHaveBeenCalled();
    });
});
