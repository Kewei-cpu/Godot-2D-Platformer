class_name FadeTransitionManager
extends ColorRect
## Fades a scene in and out.
##
## This class fades a scene in when it is loaded and 
## it fades it out when a change to the next scene is
## requested via its fade_out() method.

enum ANIMATION {
	FADE_IN, 
	FADE_OUT,
	}
	
@export var _fade_length : float = 1.5
@export var next_scene : PackedScene

var _fade_in_player_scene = preload("res://addons/sudden_fade_plugin/fade_in.tscn")
var _fade_out_player_scene = preload("res://addons/sudden_fade_plugin/fade_out.tscn")
var _fade_in_player : AnimationPlayer
var _fade_out_player : AnimationPlayer
var _next_scene : String
var _modulate_path : String

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.BLACK
	_modulate_path = String(self.get_path()) + ":self_modulate"
	size = get_viewport_rect().size
	get_tree().root.size_changed.connect(_on_window_resize)
	_fade_in_player = _create_fade_anim_player("FadeIn")
	_fade_out_player = _create_fade_anim_player("FadeOut")
	_fade_out_player.animation_finished.connect(_on_fade_out_animation_finished)
	_fade_in_player.play("Fade/FadeIn")
	
func fade_out():
	if _fade_in_player.is_playing():
		_fade_in_player.stop()
	_fade_out_player.play("Fade/FadeOut")
	
func _on_fade_out_animation_finished(anim_name: StringName) -> void:
	print(_next_scene)
	get_tree().change_scene_to_packed(next_scene)

func _create_fade_anim_player(anim_name):
	var fade_player = AnimationPlayer.new()
	var animation =_create_animation(anim_name)
	if anim_name == "FadeIn":
		_create_fade_in_track(animation)
	elif anim_name == "FadeOut":
		_create_fade_out_track(animation)
	var library = AnimationLibrary.new()
	var err = library.add_animation(anim_name, animation)
	fade_player.add_animation_library("Fade", library)
	add_child(fade_player)
	return fade_player

func _create_animation(anim_name : String):
	var animation = Animation.new()
	animation.resource_name = anim_name
	animation.length = _fade_length
	return animation

func _create_fade_in_track(animation):
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, _modulate_path)
	animation.track_insert_key(track_idx, 0.0, color)
	animation.track_insert_key(track_idx, _fade_length, Color(color, 0))
	
func _create_fade_out_track(animation):
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, _modulate_path)
	animation.track_insert_key(track_idx, 0.0, Color(color, 0))
	animation.track_insert_key(track_idx, _fade_length, Color(color, 1))
	
func _on_window_resize():
	size = get_viewport_rect().size
