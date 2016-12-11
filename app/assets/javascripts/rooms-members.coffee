@joined_user_update = (room_id) ->
	$.get("/API/member_list/#{room_id}")
	return