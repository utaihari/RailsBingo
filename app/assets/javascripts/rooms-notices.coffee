@notices_update = (room_id)->
	$.getJSON('/API/get_notices', {room_id: room_id}, (json) ->
		$('#notices').text("")
		for i in json
			$('#notices').prepend("<div><span class=\"user_name\">#{i.user_name}さん: </span> <span>#{i.notice}</span>")
		return
		)
	return