extends GameObjectBase
class_name PickableObject

const ObjectType = preload("res://scenes/scripts/Objects/ObjectType.gd").ObjectType
const SubType = preload("res://scenes/scripts/Objects/ObjectType.gd").SubType

export (ObjectType) var type: int
export (SubType) var sub_type: int
export (int) var weight: int
export (int) var contextual_value: int ##attack/def etc..
export (String) var _name: String ##should be unique
export (String) var _description: String
export (bool) var _stackable: bool
export (int) var _stack_count: int

func _ready():
	$Interactable/Name.text = _name
	if _stackable:
		assert(weight == 0) #remove a looooot of issues (we can't split stacks ..)
	if _stack_count <= 0 and _stackable:
		set_stack_count(1)
	if type == ObjectType.WEAPON and sub_type == SubType.NONE:
		assert(false)
			

func _on_Interactable_something_is_inside_interactable(body: PhysicsBody2D):
	if PDS.get_target().is_you(self):
		assert(get_type() != ObjectType.COIN) #no coin on the ground
		PDS.add_to_inventory(self)
		PDS.clear_target()

func get_weight() -> int:
	if _stackable:
		return weight * _stack_count
	else:
		return weight	

func get_object_name() -> String:
	return _name

func get_type() -> int:
	return type

func get_desc() -> String:
	return _description

func get_damages() -> int:
	##TODO range like 1 to 5
	assert(type == ObjectType.WEAPON || type == ObjectType.AMMO)
	return contextual_value

func get_defense() -> int:
	##TODO range like 1 to 5
	assert(type == ObjectType.ARMOR || type == ObjectType.SHIELD || type == ObjectType.HELMET || type == ObjectType.BOOT)
	return contextual_value	

func get_specification_desc() -> String:
	if type == ObjectType.WEAPON:
		return "It gives " + String(get_damages()) + " damages to an unarmored target."
	elif type == ObjectType.ARMOR || type == ObjectType.SHIELD || type == ObjectType.HELMET || type == ObjectType.BOOT:
		return "It gives " + String(get_defense()) + " defense points."
	elif type == ObjectType.COIN:
		return "It can be borrowed against goods and services."
	elif type == ObjectType.AMMO:
		return "It gives the equipped weapon damages + " + String(get_damages()) + " damages to an unarmored target."
	else:
		assert(false)
		return ""
		
func get_stack_count() -> int:
	assert(_stackable)
	return _stack_count
	
func set_stack_count(val : int):
	assert(val >= 0)
	assert(_stackable)
	_stack_count = max(0, val)
	if _stack_count == 0 and type != ObjectType.COIN: #cash will stay in inventory even if at 0
		queue_free()
	
func is_stackable() -> bool:
	return _stackable
	
func is_same(other: PickableObject) -> bool:
	return other.get_object_name()  == get_object_name()
	
func merge_stack(other: PickableObject):
	assert(_stackable)
	assert(is_same(other))
	assert(other != self)
	set_stack_count(get_stack_count() + other.get_stack_count())
	other.queue_free()