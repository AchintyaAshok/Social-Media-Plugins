jQuery ->

	class FacebookUser extends Backbone.Model

		initialize: ->
			self = this
			`window.fbAsyncInit = function() {
				FB.init({
				  appId      : 'XXXX', // App ID
				  channelUrl : 'XXXX', // Channel File
				  status     : true, // check login status
				  cookie     : true, // enable cookies to allow the server to access the session
				  xfbml      : true  // parse XFBML
				});`

			# subscribe to any change in the user's authorization -- if the user loses connection (by
			# logging out, or otherwise), we make sure we handle it.
			FB.Event.subscribe 'auth.authResponseChange', (response)=>
				status = response.status
				console.log('connection::status ->', status)

				if response.status == 'connected'
					@get_user_profile()
					@loggedIn = true
					window.Social.vent.trigger('user::login')

				else if response.status == 'not_authorized'
					@loggedIn = false
					window.Social.vent.trigger('user::logout')

				else
				# our status is 'unknown'
					@loggedIn = false
					window.Social.vent.trigger('user::logout')
			

			`
			};

			(function(d){
				var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
				if (d.getElementById(id)) {return;}
				js = d.createElement('script'); js.id = id; js.async = false;
				js.src = "//connect.facebook.net/en_US/all.js";
				ref.parentNode.insertBefore(js, ref);
			}(document));`


		login:(perms) ->
			responseHandler = (response)=>
				if response.authResponse
					@loggedIn = true
					window.Social.vent.trigger('login')
				else
					console.log('something went wrong with your login', response)
				return

			FB.login responseHandler, scope: 'email, user_likes, user_photos, user_checkins, user_events'


		logout: ->
			FB.logout (response)=>
				@clear() # remove all the attributes stored by the model
				@loggedIn = false


		get_user_profile: ->
			FB.getLoginStatus (response)=>
				if response.status == 'connected'
					FB.api '/me', (response)=>
						@set(response) # set the attributes of the model to the user
						console.log("get_user_profile::model -> ", @)
				else
					console.log('unable to get_user_profile')
					return false


		get_profile_picture:(callback) ->
			if !@loggedIn
				return null
			FB.api '/me/picture', (response)=>
				console.log('User Profile Picture ->', response)
				callback(response)



		get_friends: ->
			if !@loggedIn
				return null
			FB.api '/me/friends', (response)=>
				console.log('friends -> ', response)


		get_photos: ->
			if !@loggedIn
				return null
			FB.api '/me/photos', (response)=>
				console.log('photos', response)


		get_checkins: ->
			if !@loggedIn
				return null
			FB.api '/me/checkins', (response)=>
				console.log('checkins', response)
				return response

		get_locations: ->
			if !@loggedIn
				return null
			FB.api '/me/locations', (response)=>
				console.log('locations', response)
				return response



	class LoginNavbarView extends Backbone.View

		el: '#login-message'

		initialize: ->
			@facebookUser = new FacebookUser
			@model = @facebookUser

			@render()
			@facebookUser.on('change', @render) # whenever the attributes of the user changes (whether
												# he's logged in or logged out), we monitor this to re-render the login-pane

			$('#login-button').on 'click', (ev)=>
				@handle_login()
			$('#logout-button').on 'click', (ev)=>
				@handle_logout()



		render: =>
			console.log('social_stuff::render() -> facebookUser logged in?', @facebookUser.loggedIn)
			if not @facebookUser.loggedIn
				$('#logout-button').hide()
				$('#login-button').show()
				template = """
					<p class='navbar-text'>To see <em>your</em> events, </p>
				"""
				$(@el).html(template)
			
			else
				$('#logout-button').show()
				$('#login-button').hide()
				templateStr = """
					<ul class="nav">
						<li><p class='navbar-text'>Welcome <%= first_name %>!</p></li>
						<li><a href='#'>Dashboard</a></li>
				    </ul>
				"""

				template = _.template(templateStr, @model.toJSON())
				$(@el).html(template)


		handle_login: =>
			if not @facebookUser.loggedIn
				@facebookUser.login()


		handle_logout: =>
			if @facebookUser.loggedIn
				@facebookUser.logout()


		get_all_user_data: =>
			if not @facebookUser.loggedIn
				return
			@facebookUser.get_checkins()
			@facebookUser.get_locations()
			@facebookUser.get_friends()



		


	window.Social =
		"Facebook": FacebookUser
		"LoginNavbar": LoginNavbarView
		"vent": _.extend({}, Backbone.Events)
