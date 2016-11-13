$(document).on 'ready page:load', ->
	UI = new SquireUI(
		replace: 'textarea#seditor'
		buildPath: "/"
		height: 300)

	if typeof $user_detail != 'undefined'
		UI.setHTML $user_detail
	$('form').submit ->
		$('#user_detail').val(UI.getHTML()).change()
		return
	return
