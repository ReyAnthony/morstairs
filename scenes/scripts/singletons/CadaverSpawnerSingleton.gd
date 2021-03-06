extends Node

onready var _cadaver_root = get_node("/root/Level/DayNight/Level/Walls/Characters")
var _damage: PackedScene = preload("res://scenes/Scenes/Damage.tscn")

func spawn_cadaver(loot: Array, corpse: PackedScene, original_position: Vector2):
	var corpse_instance = corpse.instance()
	assert(corpse_instance is Lootable)
	_cadaver_root.add_child(corpse_instance)
	corpse_instance.global_position = original_position
	corpse_instance.setup_loot(loot)
	
func spawn_damages(damages: int, position: Vector2, player: bool):
	var dmg_scene = _damage.instance()
	_cadaver_root.add_child(dmg_scene)
	dmg_scene.global_position = position
	var damages_dealt = damages
	dmg_scene.get_node("Label").text = str(damages_dealt)
	if player:
		(dmg_scene.get_node("Label") as Label).add_color_override("font_color", Color.violet)
