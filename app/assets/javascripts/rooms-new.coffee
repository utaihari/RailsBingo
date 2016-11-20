$(document).on 'ready page:load', ->
	UI = new SquireUI(
		replace: 'textarea#seditor'
		buildPath: "/"
		height: 300)

	if typeof $room_detail != 'undefined'
		UI.setHTML $room_detail
	$('form').submit ->
		$('#room_detail').val(UI.getHTML()).change()
		return
	return