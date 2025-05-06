class_name Effect
extends PanelContainer

@onready var effect_timer: Timer = $EffectTimer
@onready var effect_texture: TextureRect = $MarginContainer/EffectTexture
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: Player
var flickering := false

func _ready() -> void:
	player = get_node("../../../../")
	on_effect_start()
	
	effect_timer.timeout.connect(on_effect_end)
	effect_timer.timeout.connect(queue_free)

func _process(_delta: float) -> void:
	if effect_timer.is_stopped():
		return
	
	on_effect_last()
		
	if effect_timer.time_left <= 3 and not flickering:
		animation_player.play("flicker")
		flickering = true
		
func on_effect_start():
	pass

func on_effect_last():
	pass

func on_effect_end():
	pass
