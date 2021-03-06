extends GameObjectBase
class_name Lootable

var money = preload("res://scenes/Scenes/Objects/Coin.tscn")
export(int) var _min_money: int
export(int) var _max_money: int

func _ready():
	$Content.hide()
	
func _on_Interactable_something_is_inside_interactable(body: PhysicsBody2D):
	if body.is_in_group("player") and PDS.get_target().is_you(self): ## and !PDS.is_fighting():
		PDS.clear_target()
		PDS.get_player_ui_manager().show_inventory_and_loot($Content.get_children(), $Content)

func setup_loot(loot: Array):
	for l in loot:
		l.get_parent().remove_child(l)
		$Content.add_child(l)
		l.position = Vector2.ZERO
	_add_money(_min_money, _max_money)
		
func _add_money(amount_min: int, amount_max: int):
	var cash = money.instance() as PickableObject
	var amount = rand_range(amount_min, amount_max)
	amount = int(ceil(amount))
	cash.set_stack_count(amount)
	$Content.add_child(cash)
	