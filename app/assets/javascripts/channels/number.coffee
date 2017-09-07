# App.number = App.cable.subscriptions.create {channel: "NumberChannel", room: @room_id},
# 	connected: ->
# 		# Called when the subscription is ready for use on the server
# 		console.log("number connected")
# 	disconnected: ->
# 		# Called when the subscription has been terminated by the server

# 	received: (data) ->
# 		# Called when there's incoming data on the websocket for this channel
# 		@receive_number(data['number'])
# 		console.log("number received")