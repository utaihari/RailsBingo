notices_length = 0
notice_auto_update = false

@notice_auto_update = =>
	room_id = $("#data").data("room_id")
	if !notice_auto_update
		@update_notice = setInterval(->
			@notices_update(room_id)
		,1500)
		$('#notice-update-button').text("自動更新中")
		notice_auto_update = true
	else
		clearInterval(@update_notice)
		$('#notice-update-button').text("自動更新する")
		notice_auto_update = false
	return

@notices_update = (room_id) ->
	$.getJSON('/API/get_notices', {room_id: room_id, length: notices_length}, (json) ->
		if json != null
			json.reverse()
			notices_length += json.length
			for i in json
				$('#notices').prepend("<div><span class=\"user_name\">#{i.user_name}さん: </span><span><font color=\"#{i.color}\">#{i.notice}</font></span>")
			return
		)
	return