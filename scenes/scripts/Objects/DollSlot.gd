extends Slot
class_name DollSlot

const ObjectType = preload("res://scenes/scripts/Objects/ObjectType.gd").ObjectType
var _inventory_info_panel: InventoryInfoPanel
export (ObjectType) var slot_type: int

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	_inventory_info_panel = $"../../../InfoPanel"
	_inventory_info_panel.reset()

func can_drop_data(position, data):
	var ret = .can_drop_data(position, data)
	return ret and data.get_type() == slot_type

func _on_mouse_entered():
	if is_empty():
		return
	var o = get_object_in_slot()
	_inventory_info_panel.update_panel(o)

func _on_mouse_exited():
	_inventory_info_panel.reset()
	
func drop_data(position, data):
	##allow moving from inventory slot to doll slot even if full
	var player_inventory = $"../../../"
	var bag = $"../../../Bag"
	var chara_doll = $"../../"
	if bag.is_full() or player_inventory._is_it_too_heavy_with_new(data) and data.get_parent() is LootSlot:
		player_inventory.show_is_full()
		return
	.drop_data(position, data)