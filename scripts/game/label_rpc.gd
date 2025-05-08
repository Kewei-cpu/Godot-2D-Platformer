class_name LabelRPC
extends Label

@rpc("call_local", "any_peer")
func show_rpc():
	show()


@rpc("call_local", "any_peer")
func hide_rpc():
	hide()


@rpc("call_local", "any_peer")
func set_text_rpc(_text: String):
	text = _text
