extends Slot
class_name InventorySlot

var _info_panel: InventoryInfoPanel

func _ready():
	_info_panel = $"../../InfoPanel"
	_info_panel.reset()

func _on_mouse_entered():
	._on_mouse_entered()
	if is_empty():
		return
	var o = get_object_in_slot()	
	_info_panel.update_panel(o)

func _on_mouse_exited():
	._on_mouse_exited()
	##_info_panel.reset()
	pass
	
func drop_data(position, data):
	if $"../".is_full() or $"../../"._is_it_too_heavy_with_new(data) and data.get_parent() is LootSlot:
		$"../../".show_is_full()
		return
	.drop_data(position, data)
	
func can_drop_data(position, data):
	return .can_drop_data(position, data) and data.get_type() != 8 ##coin