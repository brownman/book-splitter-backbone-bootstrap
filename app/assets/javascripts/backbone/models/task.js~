TodoList.Models.Task = Backbone.Model.extend({

  defaults: {
    name: '',
    complete: false
  },

  url: function() {
    if (this.isNew()) {
      return "/tasks.json";
    } else {
      return "/tasks/" + this.id + ".json";
    }
  },

  toJSON: function() {
    return { task: this.attributes };
  },

  getId: function() {
    return this.get('id');
  },

  getName: function() {
    return this.get('name');
  },

  getComplete: function() {
    return this.get('complete');
  },
 replace :function(str, sym) {
                 for (var i = 0; i <  sym.length ; i++) {
                     str = this.replace_one(str, sym[i]);
                     //str.replace(sym[i], sym[i].concat('='));
                 }

                 //.replace(",", ",=");
                 return str;
             },
    replace_one : function(story,sign)
    {
        //sign = "."
       var  to_sign = sign + "$"
        var    from="[" + sign  + "]"
       var     from_reg = new RegExp(from,"g");

        var str = story.replace(from_reg , to_sign);
        return str;
    },

    split : function(){
var str  = this.get('name')
                var story_enc = str 

                story_enc =  story_enc.replace(/\n/g, " ");

                    var arr_symbols = [',', '!', '.', "?", ":", ";", "=" ]
                    story_enc = this.replace(story_enc, arr_symbols);



                //split   replace
                var story_arr = story_enc.split('$');

                //    console.log(story_arr);

                //each symbol to replace str
                //            this.trace(story_arr);
                return story_arr

            }
                 



});
TodoList.Collections.Tasks = Backbone.Collection.extend({

  url: '/tasks.json',
  model: TodoList.Models.Task,

  parse: function(response) {
    return response.tasks;
  }

});
