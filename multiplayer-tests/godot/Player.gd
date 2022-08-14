extends KinematicBody2D

const UPDATE_FRAMES = 6

export (bool) var player_controlled = false
export (PackedScene) var bullet

var velocity := Vector2.ZERO
var direction := 0
var current_frame := 0

signal Player_has_died()

func _physics_process(delta):
	if player_controlled:
		velocity = Vector2.ZERO
		velocity.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		velocity = move_and_slide(velocity * 100, Vector2.UP)
		look_at(get_global_mouse_position())
		
		# TODO: use delta instead of current_frame?
		if current_frame <= UPDATE_FRAMES:
			rpc("UpdateRemotePlayers", position, rotation)
			current_frame = 0
		current_frame += 1

puppet func UpdateRemotePlayers(current_pos, current_rot):
	position = current_pos
	rotation = current_rot
