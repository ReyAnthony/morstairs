extends KinematicBody2D
class_name NPC

signal on_dialog_end
signal is_attacked(attacker)

export (Material) var material_on_mouse_enter: Material
export (String)  var chara_name: String
export (Texture) var chara_portrait: Texture
export (Array, String) var messages: Array = []

var can_be_hit := false
var _dialog := true

func attack(amount: int, attacker: PhysicsBody2D):
	$Stats.attack(amount)
	_dialog = false
	emit_signal("is_attacked", attacker)

func _ready():
	assert($Sprite != null)
	assert($Interactable != null)
	self.add_to_group("npc")
	if $Stats != null:
		can_be_hit = true

	$Interactable.connect("mouse_clicked", self, "_on_Interactable_mouse_clicked")
	$Interactable.connect("mouse_entered", self,  "_on_Interactable_mouse_entered")
	$Interactable.connect("mouse_exited", self, "_on_Interactable_mouse_exited")
	$Interactable.connect("something_is_inside_interactable", self, "_on_Interactable_something_is_inside_interactable")
	
	$Interactable/Name.text = chara_name
	
func _on_DialogPanel_on_dialog_end():
	PlayerDataSingleton.clear_target()
	emit_signal("on_dialog_end")

func _on_Interactable_mouse_clicked():
	PlayerDataSingleton.set_target(global_position, self)

func _on_Interactable_mouse_entered():
	$Sprite.material = material_on_mouse_enter

func _on_Interactable_mouse_exited():
	$Sprite.material = null

func _on_Interactable_something_is_inside_interactable(body: PhysicsBody2D):
	if !PlayerDataSingleton.get_target().is_valid() or !_dialog:
		return
	if !PlayerDataSingleton.fight_mode && PlayerDataSingleton.get_target().node == self:
		($CanvasLayer/DialogPanel as DialogPanel).my_popup(chara_name, chara_portrait, messages)
		PlayerDataSingleton.clear_target()
