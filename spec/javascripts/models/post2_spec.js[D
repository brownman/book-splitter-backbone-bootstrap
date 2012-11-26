/**
 * NOTE: At this point we're test driving the sample Todo list app.
 *       You'll be refering to js/todos.js quite a bit from now on,
 *       so make sure you have it open.
 */
describe('About Backbone.Model', function() {
window.Todo = RailsBackboneRelational.Models.Post

    it('A Model can have default values for its attributes.', function() {
        var todo = new Todo();

        var defaultAttrs = {
            title: 'title?'
        }

        expect(defaultAttrs['title']).toEqual(todo.attributes['title']);
    });

    it('Attributes can be set on the model instance when it is created.', function() {
        var todo = new Todo({ title: 'title1' });

        expect(todo.get('title')).toEqual('title1');
    });

    it('If it is exists, an initialize function on the model will be called when it is created.', function() {

        // Why does the expected text differ from what is passed in when we create the Todo?
        // What is happening in Todo.initialize? (see js/todos.js line 22)
        // You can get this test passing without changing todos.js or actualText.
        var todo = new Todo({ title: 'a-b' });

        actualText = 'a_b'; // Don't change
        expect(todo.sanitize1(actualText)).toBe('a-b');
    });

    it('Fires a custom event when the state changes.', function() {
        var callback = jasmine.createSpy('-change event callback-');

        var todo = new Todo({title: 'title..'});

        todo.on('change', callback);

        // How would you update a property on the todo here?
        // Hint: http://documentcloud.github.com/backbone/#Model-set
        todo.set(
                 {title: 'abc'}
                )
        expect(callback).toHaveBeenCalled();
    });

    it('Can contain custom validation rules, and will trigger an error event on failed validation.', function() {
        var errorCallback = jasmine.createSpy('-error event callback-');

        var todo = new Todo({title: 'xx'});

        todo.on('error', errorCallback);

        // What would you need to set on the todo properties to cause validation to fail?
        // Refer to Todo.validate in js/todos.js to see the logic.

        todo.set(
            {
                title:  null
            }
            )

        var errorArgs = errorCallback.mostRecentCall.args;
        console.log(
            errorCallback
            )


        expect(errorCallback).toBeDefined();

          expect(errorArgs).toBeDefined();

         expect(errorArgs[0]).toBe(todo);

         expect(errorArgs[1]).toBe(
                 'attr.direction must be a non null value.'
                 );
            });
});
