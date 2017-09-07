# App.room_condition = App.cable.subscriptions.create {channel: "RoomConditionChannel", room: @room_id},
# 	connected: ->
# 		# Called when the subscription is ready for use on the server
# 		console.log("room_condition connected")
# 	disconnected: ->
# 		# Called when the subscription has been terminated by the server

# 	received: (data) ->
# 		# Called when there's incoming data on the websocket for this channel
# 		@receive_notice(data['notice'])
# 		console.log("room_condition received")