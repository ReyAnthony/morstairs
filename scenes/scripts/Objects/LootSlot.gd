extends Slot
class_name LootSlot

var _inventory_info_panel: InventoryInfoPanel

func _ready():
	_inventory_info_panel = $"../../../InfoPanel"

func _on_mouse_entered():
	._on_mouse_entered()
	if is_empty():
		return
	var o = get_object_in_slot()
	_inventory_info_panel.update_panel(o)

func _on_mouse_exited():
	._on_mouse_exited()
	##_inventory_info_panel.reset()
	pass