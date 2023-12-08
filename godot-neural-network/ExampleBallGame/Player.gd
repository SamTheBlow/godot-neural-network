extends KinematicBody2D

var velocity = Vector2.ZERO
var gravity = 10

func _process(_delta):
	$Ghost.global_position = position

func set_ghost_transparency(transparency):
	var brightness = 0.75
	$Ghost.modulate.r = brightness
	$Ghost.modulate.g = brightness
	$Ghost.modulate.b = brightness
	$Ghost.modulate.a = transparency

func get_actions() -> PoolRealArray:
	var output = [0.0, 0.0, 0.0]
	
	if Input.is_action_pressed("move_left"):
		output[0] = 1.0
	if Input.is_action_pressed("move_right"):
		output[1] = 1.0
	if Input.is_action_pressed("jump"):
		output[2] = 1.0
	
	return output

# To be called in a _physics_process()
func do_actions(actions: PoolRealArray):
	var direction = Vector2.ZERO
	
	if actions[0] >= 0.5:
		direction.x -= 1
	if actions[1] >= 0.5:
		direction.x += 1
	if actions[2] >= 0.5:
		if is_on_floor():
			direction.y = -20
	
	velocity += direction * 20
	velocity.y += gravity
	
# warning-ignore:return_value_discarded
	velocity = move_and_slide(velocity, Vector2.UP)
