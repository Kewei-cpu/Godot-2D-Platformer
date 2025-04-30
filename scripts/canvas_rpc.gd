class_name CanvasLayerRPC

extends CanvasLayer

@rpc("call_local", "any_peer")
func show_rpc():
	show()
	
@rpc("call_local", "any_peer")
func hide_rpc():
	hide()
