# Call load_ai() to load an AI from existing data
extends Node2D

var ball_scene = preload("res://ExampleBallGame/Ball.tscn")
var ball

# Variables to be set up by whatever is building this scene
var ai
var player_controlled = true
var show_interface = false
var ghost_transparency = 0.1

# Number of balls successfully launched into the net
var goals = 0

func _ready():
	$Player.set_ghost_transparency(ghost_transparency)
	$InterfaceCanvas.visible = show_interface
	spawn_ball()

func _process(_delta):
	# Punish the AI if the ball goes too fast
	# We want the AI to make clean-looking shots!
	# But more importantly, we want them to not abuse glitches :)
	if ball.linear_velocity.length() >= 1800:
		ai.score -= floor(ball.linear_velocity.length() * 0.01)
	
	# Reward the AI if the ball is close to the net
	if ball.is_inside_tree():
		var x = ball.global_position.x - global_position.x
		var y = ball.global_position.y
		# The ball is on the right side of the screen? POINTS FOR YOU!
		if y > 0 && y < 1080 * 0.7 && x > 1920 * 0.5:
			ai.score += 10
		# The ball got super close to the net? BONUS POINTS!!!
		if y > 1080 * 0.1 && y < 1080 * 0.5 && x > 1920 * 0.7:
			ai.score += 100

func _physics_process(_delta):
	var inputs = get_ai_inputs()
	var actions
	
	if player_controlled:
		actions = $Player.get_actions()
	else:
		actions = ai.inputs_to_outputs(inputs)
	
	# The AI's score (not the number of goals!)
	$InterfaceCanvas/Score.text = "Score: " + String(ai.score)
	$InterfaceCanvas/BrainInputs.text = "Input: " + String(inputs)
	$InterfaceCanvas/BrainOutputs.text = "Output: " + String(actions)
	$Player.do_actions(actions)

### Functions for converting stuff into AI inputs
func get_ai_inputs() -> PoolRealArray:
	var ball_pos_x:float = 0
	var ball_pos_y:float = 0
	var ball_vel_x:float = 0.5
	var ball_vel_y:float = 0.5
	if ball.is_inside_tree():
		ball_pos_x = normalize_float_linear(ball.global_position.x - global_position.x, 0, 1920)
		ball_pos_y = normalize_float_linear(ball.global_position.y, 0, 1080)
		ball_vel_x = normalize_float_inverse(ball.linear_velocity.x)
		ball_vel_y = normalize_float_inverse(ball.linear_velocity.y)
	
	var player_pos_x:float = 0
	var player_pos_y:float = 0
	var player_vel_x:float = 0.5
	var player_vel_y:float = 0.5
	if true:
		player_pos_x = normalize_float_linear($Player.global_position.x - global_position.x, 0, 1920)
		player_pos_y = normalize_float_linear($Player.global_position.y, 0, 1080)
		player_vel_x = normalize_float_inverse($Player.velocity.x)
		player_vel_y = normalize_float_inverse($Player.velocity.y)
	
	var inputs = []
	inputs.append(player_pos_x)
	inputs.append(player_pos_y)
	inputs.append(ball_pos_x)
	inputs.append(ball_pos_y)
	inputs.append(player_vel_x)
	inputs.append(player_vel_y)
	inputs.append(ball_vel_x)
	inputs.append(ball_vel_y)
	return inputs

func normalize_float_linear(value, minimum, maximum) -> float:
	if value <= minimum:
		value = 0
	elif value > maximum:
		value = 1
	else:
		value = (value - minimum) / (maximum - minimum)
	return value

func normalize_float_inverse(value) -> float:
	if value > -1 && value < 1:
		value = 0.5
	elif value >= 1:
		value = 1 - (1 / value) * 0.5
	elif value <= -1:
		value = -(1 / value) * 0.5
	return value
###

func _on_Net_body_entered(body):
	if body.global_position.y < $Net/Net.global_position.y:
		goals += 1
		# Give the AI a big juicy reward
		ai.score += 100000
		ball.queue_free()
		spawn_ball()

func _on_Ball_body_entered(body):
	# Reward the AI slightly for hitting the ball
	if body == $Player:
		ai.score += 100

func spawn_ball():
	ball = ball_scene.instance()
	ball.position.x = randf() * 800 + 100
	ball.position.y = randf() * 500 + 200
	ball.rotation = randf() * PI * 2
	ball.cursor_canvas = $CursorCanvas
	ball.top_of_screen = $Boundaries/Top
	ball.ghost_transparency = ghost_transparency
	ball.connect("body_entered", self, "_on_Ball_body_entered")
	$Balls.call_deferred("add_child", ball)
