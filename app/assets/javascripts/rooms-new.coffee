$(document).on 'ready page:load', ->
	UI = new SquireUI(
		replace: 'textarea#seditor'
		buildPath: "/"
		height: 300)

	$('form').submit ->
		$('#room_detail').val(UI.getHTML()).change()
		return

	if typeof $room_detail != 'undefined'
		UI.setHTML $room_detail

	return
@show_room_detail = ->
	console.log("show")
	$('#item-setting').toggle()
	return