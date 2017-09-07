# App.notice = App.cable.subscriptions.create {channel: "NoticeChannel", room: @room_id},
# 	connected: ->
# 	# Called when the subscription is ready for use on the server
# 		console.log("notice connected")
# 	disconnected: ->
# 	# Called when the subscription has been terminated by the server


# 	received: (data) ->
# 		# Called when there's incoming data on the websocket for this channel
# 		console.log("notice received")
# 		@receive_notice(data)