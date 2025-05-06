class_name Inventory
extends CanvasLayer

@onready var indicator_margin: MarginContainer = %IndicatorMargin

@onready var item_icon_0: TextureRect = %ItemIcon0
@onready var item_icon_1: TextureRect = %ItemIcon1
@onready var item_icon_2: TextureRect = %ItemIcon2
@onready var item_icon_3: TextureRect = %ItemIcon3
@onready var item_icon_4: TextureRect = %ItemIcon4

@onready var inventory_icon_list: Array[TextureRect] = [item_icon_0, item_icon_1, item_icon_2, item_icon_3, item_icon_4]

var inventory: Array[Collectable] = [null, null, null, null, null]
var current_slot = 0


func handle_slot_change():
	if Input.is_action_just_pressed("Slot 0"):
		change_inventory_slot(0)

	if Input.is_action_just_pressed("Slot 1"):
		change_inventory_slot(1)

	if Input.is_action_just_pressed("Slot 2"):
		change_inventory_slot(2)

	if Input.is_action_just_pressed("Slot 3"):
		change_inventory_slot(3)

	if Input.is_action_just_pressed("Slot 4"):
		change_inventory_slot(4)

	if Input.is_action_just_pressed("Previous Slot"):
		change_inventory_slot((current_slot + 4) % 5)

	if Input.is_action_just_pressed("Next Slot"):
		change_inventory_slot((current_slot + 1) % 5)


func handle_item_use():
	if Input.is_action_just_pressed("item_use"):
		if inventory[current_slot] == null:
			return

		var item: Collectable = inventory[current_slot]

		if not item.useable:
			return

		var discard := not item.on_player_use()
		if discard:
			remove_item_from_inventory_slot(current_slot)


func change_inventory_slot(slot: int) -> void:
	if slot > 4 or slot < 0:
		return
	indicator_margin.add_theme_constant_override("margin_left", 68 * slot)
	current_slot = slot


func get_empty_inventory_slot() -> int:
	# if the selected is empty, return the selected slot
	# otherwise return the first empty slot
	# if inventory is full, return -1
	if inventory[current_slot] == null:
		return current_slot

	for slot in range(5):
		if inventory[slot] == null:
			return slot

	return -1


func add_item_to_inventory(item: Collectable) -> bool:
	# return whether there's room to pick up
	var slot := get_empty_inventory_slot()

	if slot == -1:
		return false

	add_item_to_inventory_slot(item, slot)
	return true


func add_item_to_inventory_slot(item: Collectable, slot: int):
	# no safety check, please be cautious!
	item.call_deferred("reparent", get_parent())
	inventory[slot] = item
	inventory_icon_list[slot].texture = item.icon_texture


func remove_item_from_inventory_slot(slot: int):
	inventory[slot] = null
	inventory_icon_list[slot].texture = null
