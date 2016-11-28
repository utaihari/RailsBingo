@joined_user_update = () ->
	members = []
	$.ajaxSetup({async: false});
	$.getJSON('/API/joined_users',{room_id: @room_id},(json)->
		members = json
	)
	list = $('#members')
	$(list).empty()
	for user, index in members
		$(list).prepend("<div class=\"member\">#{user.name}</div>")
	return