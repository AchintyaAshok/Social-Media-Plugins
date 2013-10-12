What is this?

This is a collection of social media plugins that you can use in your application. For example, if you wanted to integrate your application with facebook, you would:

1) register your application & get all the necessarry keys
2) use my plugin to commmunicate with facebook and handle user data through a simple OOP-based interface. (at least that's the idea)

How do I integrate this with my code?

The plugins will require the use of the standard jquery plugin (that I'm sure you already make use of) and additionally (and crucially) backbone.js. Finally, if you intend to use this with your application, you must have a method of compiling this coffeescript code into javascript. 

If you have the fortune of using Ruby On Rails, simply add the coffee gem to your application, place the plugin in your app/assets/javascripts folder and modify your application.js file to compile the plugin when loading the application. Also, make sure you include the jquery & backbone.js javascripts as noted above.

