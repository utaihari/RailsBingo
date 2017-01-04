@joined_user_update = (room_id) ->
	$.get("/API/member_list/#{room_id}")
	return
@show_ip_address = ->
	$('.ip-address').toggle()
	return