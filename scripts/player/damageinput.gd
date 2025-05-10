extends CanvasLayer

@onready var player_name_input: LineEdit = $Panel/VBoxContainer/name
@onready var damage_input: LineEdit = $Panel/VBoxContainer/damage
@onready var confirm_button: Button = $Panel/VBoxContainer/HBoxContainer/confirm
@onready var cancel_button: Button = $Panel/VBoxContainer/HBoxContainer/cancel
@onready var ud: LineEdit = $Panel/VBoxContainer/updown
@onready var lr: LineEdit = $Panel/VBoxContainer/leftright
@onready var hb: LineEdit = $Panel/VBoxContainer/hitback
var game: Game

func _ready():
	# 在 DamageInputUI.gd 的 _ready() 里设置
	self.layer = 10000  # 设置一个较高的值确保它在最前面
	game = get_node("/root/Game")  # 根据你的实际路径调整
	#confirm_button.pressed.connect(_on_confirm_pressed)
	#cancel_button.pressed.connect(_on_cancel_pressed)
	#hide()
	show()
func _process(delta: float) -> void:
	pass
	if Input.is_key_pressed(KEY_O):
		show_ui()
func _on_confirm_pressed():
	var player_name = player_name_input.text
	var damage = damage_input.text.to_int()
	
	if player_name.is_empty():
		print("Invalid input!")
		return
	
	# 查找指定名称的玩家
	for player in game.get_children():
		if player is Player and player.name_tag.text == player_name:
			# 模拟子弹击中效果，使用随机方向和击退力
			var collision_normal 
			if ud.text.is_empty() and lr.text.is_empty():
				
				collision_normal = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			else:
				collision_normal = Vector2(ud.text.to_int(), lr.text.to_int()).normalized()
			var hitback = hb.text.to_int()  # 击退力
			
			# 调用bullet_hit函数
			player.bullet_hit.rpc_id(player.get_multiplayer_authority(), damage, collision_normal, hitback,0,DeathCause.DeathCause.UNKNOWN)
			break
	
	##hide()

func _on_cancel_pressed():
	hide()

func show_ui():
	player_name_input.clear()
	damage_input.clear()
	show()
	player_name_input.grab_focus()
