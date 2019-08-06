extends KinematicBody2D
class_name Player

export (Texture) var player_portrait: Texture
export (NodePath) var map_cam: NodePath

const _WALK_SPEED := 30
const _PDS: PDS = PlayerDataSingleton
var _velocity := Vector2()
var _last_dir := "NW"
var _is_attacking := false
var _map_cam :Camera

func attack(amount: int):
	$Stats.attack(amount)

func _ready():
	$AnimatedSprite.play("NW")
	add_to_group("player")
	_map_cam = get_node(map_cam)
	$Interactable.connect("something_is_inside_interactable", self, "_on_player_npc_is_inside_action_zone")
	$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	_PDS.connect("target_has_changed", self, "_update_targeting")
	$CanvasLayer/Panel/CombatMode.connect("pressed", self, "_on_combat_mode_switch")
	$CanvasLayer/Panel/Inventory.connect("pressed", self, "_on_show_inventory")
	$CanvasLayer/Panel/Player/Portrait.connect("pressed", self, "_on_show_player_stats")
	
# warning-ignore:unused_argument
func _process(delta: float):	
	var anim_direction := ""
	var anim := ""
	var target: PlayerTarget = _PDS.get_target()
	_update_player_life()
		
	if  target.is_valid():
		_velocity = (target.get_position() - self.global_position).normalized()
		anim_direction += _determine_sprite_direction()
		if target.get_position().distance_to(self.global_position) < 2:
			_PDS.clear_target()
			_velocity = Vector2.ZERO
	else:
		_is_attacking = false
		_velocity = Vector2.ZERO

	if _PDS.fight_mode:
		anim = "_FIGHT"
		if _is_attacking and _PDS.get_target().is_valid():
			anim += "_MELEE_ATTACK"

	if anim_direction != "":
		$AnimatedSprite.play(anim_direction + anim)
		_last_dir = anim_direction
	if _velocity.length() < 0.1:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	
	if !_is_attacking:
		move_and_slide(_velocity.normalized() * _WALK_SPEED)
		var has_collided_with_target = false
		for i in get_slide_count():
			var collision: KinematicCollision2D = get_slide_collision(i)
			if !(collision.collider.name == "TalkingNPC" and _PDS.fight_mode):
				_PDS.clear_target()
				_velocity = Vector2.ZERO

func _determine_sprite_direction():
	var dir = ""
	if _velocity.y > 0:
		dir += "S"
	elif _velocity.y < 0:
		dir += "N"
	if _velocity.x < 0:
		dir += "W"
	elif _velocity.x > 0:
		dir += "E"
	return dir

func _on_AnimatedSprite_animation_finished():
	var target: PlayerTarget = _PDS.get_target()
	if !target.is_valid() or target.targetType != target.TargetType.ACTION_TARGET:
		_is_attacking = false
		return
	if _is_attacking \
		and target.is_valid() \
		and target.targetType == target.TargetType.ACTION_TARGET \
		and target.node.can_be_hit \
		and $AnimatedSprite.animation.ends_with("MELEE_ATTACK")\
		and $Interactable/ActionArea.overlaps_body(target.node):
			target.node.attack(1, self)		
	_is_attacking = false
			
# warning-ignore:unused_argument
func _unhandled_input(event: InputEvent):
	if Input.is_action_pressed("mouse_left_click"):
		_is_attacking = false
		_PDS.set_target(get_global_mouse_position())
	else:
		_velocity = Vector2.ZERO
		
func _on_player_npc_is_inside_action_zone(body: PhysicsBody2D):
	var target: PlayerTarget = _PDS.get_target()	
	if !target.is_valid() or !_PDS.fight_mode or target.targetType != target.TargetType.ACTION_TARGET:
		return
	if target.node == body and !target.node.can_be_hit:
		_is_attacking = false
		_PDS.clear_target()
	elif target.node == body:
		_is_attacking = true

func _on_combat_mode_switch():
	_PDS.clear_target()
	if _PDS.fight_mode: 
		$AnimatedSprite.play(_last_dir)
	else:
		$AnimatedSprite.play(_last_dir + "_FIGHT")
	_PDS.fight_mode = !_PDS.fight_mode
	
func _on_show_inventory():
	get_tree().paused = true
	$CanvasLayer/PlayerInventory.show_inventory()

func _update_targeting(target: PlayerTarget):
	if target.is_valid() and target.targetType == target.TargetType.ACTION_TARGET and target.node.can_be_hit:
		$CanvasLayer/Life/Target.show()
		$CanvasLayer/Life/Target/Label.text = target.node.chara_name
		$CanvasLayer/Life/Target/Portrait.texture = target.node.chara_portrait
		$CanvasLayer/Life/Target/ColorRect.rect_size.x = target.node.get_life() * (77 / target.node.get_max_life())
	else:
		$CanvasLayer/Life/Target.hide()
		
func _update_player_life():
	$CanvasLayer/Panel/Player/Label.text = _PDS.get_player_name()
##	$CanvasLayer/Panel/Player/Portrait. = player_portrait
	$CanvasLayer/Panel/Player/ColorRect.rect_size.x = $Stats._current_life * (77 / $Stats.life)