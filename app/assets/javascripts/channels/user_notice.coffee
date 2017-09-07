# App.user_notice = App.cable.subscriptions.create {channel: "UserNoticeChannel", user_id: @user_id},
# 	connected: ->
# 		# Called when the subscription is ready for use on the server
# 		console.log("user_notice connected")
# 	disconnected: ->
# 		# Called when the subscription has been terminated by the server

# 	received: (data) ->
# 		# Called when there's incoming data on the websocket for this channel
# 		@receive_notice(data['notice'])
# 		console.log("user_notice received")