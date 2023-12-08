class_name Player
extends CharacterBody2D


var gravity: float = 10.0

@onready var ghost := $Ghost as Sprite2D


func _process(_delta: float) -> void:
	ghost.global_position = position


func set_ghost_transparency(transparency: float) -> void:
	var brightness: float = 0.75
	ghost.modulate.r = brightness
	ghost.modulate.g = brightness
	ghost.modulate.b = brightness
	ghost.modulate.a = transparency


func get_actions() -> Array[float]:
	var output: Array[float] = [0.0, 0.0, 0.0]
	
	if Input.is_action_pressed("move_left"):
		output[0] = 1.0
	if Input.is_action_pressed("move_right"):
		output[1] = 1.0
	if Input.is_action_pressed("jump"):
		output[2] = 1.0
	
	return output


# To be called in a _physics_process()
func do_actions(actions: Array[float]) -> void:
	var direction := Vector2.ZERO
	
	if actions[0] >= 0.5:
		direction.x -= 1.0
	if actions[1] >= 0.5:
		direction.x += 1.0
	if actions[2] >= 0.5:
		if is_on_floor():
			direction.y = -20.0
	
	velocity += direction * 20.0
	velocity.y += gravity
	move_and_slide()
