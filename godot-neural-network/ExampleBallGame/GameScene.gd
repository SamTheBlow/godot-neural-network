class_name Game
extends Node2D
## Call load_ai() to load an AI from existing data


var ball_scene := preload("res://ExampleBallGame/Ball.tscn") as PackedScene
var ball: Ball

# Variables to be set up by whatever is building this scene
var ai: NeuralNetworkAI
var player_controlled: bool
var show_interface: bool
var ghost_transparency: float = 0.1
#

## Number of balls successfully launched into the net
var goals: int = 0

@onready var player := $Player as Player
@onready var net := $Net/Net as Area2D
@onready var interface_canvas := $InterfaceCanvas as CanvasLayer
@onready var score := $InterfaceCanvas/Score as Label
@onready var brain_inputs := $InterfaceCanvas/BrainInputs as Label
@onready var brain_outputs := $InterfaceCanvas/BrainOutputs as Label


func _ready() -> void:
	player.set_ghost_transparency(ghost_transparency)
	interface_canvas.visible = show_interface
	spawn_ball()


func _process(_delta: float) -> void:
	# Punish the AI if the ball goes too fast
	# We want the AI to make clean-looking shots!
	# But more importantly, we want them to not abuse glitches :)
	if ball.linear_velocity.length() >= 1800.0:
		ai.score -= floori(ball.linear_velocity.length() * 0.01)
	
	# Reward the AI if the ball is close to the net
	if ball.is_inside_tree():
		var x: float = ball.global_position.x - global_position.x
		var y: float = ball.global_position.y
		# The ball is on the right side of the screen? POINTS FOR YOU!
		if y > 0 and y < 1080 * 0.7 and x > 1920 * 0.5:
			ai.score += 10
		# The ball got super close to the net? BONUS POINTS!!!
		if y > 1080 * 0.1 and y < 1080 * 0.5 and x > 1920 * 0.7:
			ai.score += 100


func _physics_process(_delta: float) -> void:
	var inputs: Array[float] = get_ai_inputs()
	var actions: Array[float]
	
	if player_controlled:
		actions = player.get_actions()
	else:
		actions = ai.inputs_to_outputs(inputs)
	
	# The AI's score (not the number of goals!)
	score.text = "Score: " + str(ai.score)
	brain_inputs.text = "Input: " + str(inputs)
	brain_outputs.text = "Output: " + str(actions)
	
	player.do_actions(actions)


func get_ai_inputs() -> Array[float]:
	var ball_pos_x: float = 0.0
	var ball_pos_y: float = 0.0
	var ball_vel_x: float = 0.5
	var ball_vel_y: float = 0.5
	if ball.is_inside_tree():
		ball_pos_x = normalize_float_linear(ball.global_position.x - global_position.x, 0, 1920)
		ball_pos_y = normalize_float_linear(ball.global_position.y, 0, 1080)
		ball_vel_x = normalize_float_inverse(ball.linear_velocity.x)
		ball_vel_y = normalize_float_inverse(ball.linear_velocity.y)
	
	var player_pos_x: float = 0.0
	var player_pos_y: float = 0.0
	var player_vel_x: float = 0.5
	var player_vel_y: float = 0.5
	if true:
		player_pos_x = normalize_float_linear(player.global_position.x - global_position.x, 0, 1920)
		player_pos_y = normalize_float_linear(player.global_position.y, 0, 1080)
		player_vel_x = normalize_float_inverse(player.velocity.x)
		player_vel_y = normalize_float_inverse(player.velocity.y)
	
	var inputs: Array[float] = []
	inputs.append(player_pos_x)
	inputs.append(player_pos_y)
	inputs.append(ball_pos_x)
	inputs.append(ball_pos_y)
	inputs.append(player_vel_x)
	inputs.append(player_vel_y)
	inputs.append(ball_vel_x)
	inputs.append(ball_vel_y)
	return inputs


func normalize_float_linear(value: float, minimum: int, maximum: int) -> float:
	return clampf((value - minimum) / (maximum - minimum), 0.0, 1.0)


func normalize_float_inverse(value: float) -> float:
	if value > -1.0 and value < 1.0:
		value = 0.5
	elif value >= 1.0:
		value = 1.0 - (1.0 / value) * 0.5
	elif value <= -1.0:
		value = -(1.0 / value) * 0.5
	return value


func _on_net_body_entered(body: Node2D) -> void:
	if body.global_position.y < net.global_position.y:
		goals += 1
		# Give the AI a big juicy reward
		ai.score += 100000
		ball.queue_free()
		spawn_ball()


func _on_ball_body_entered(body: Node2D) -> void:
	# Reward the AI slightly for hitting the ball
	if body == player:
		ai.score += 100


func spawn_ball() -> void:
	ball = ball_scene.instantiate() as Ball
	ball.position.x = randf() * 800 + 100
	ball.position.y = randf() * 500 + 200
	ball.rotation = randf() * PI * 2
	ball.cursor_canvas = $CursorCanvas as CanvasLayer
	ball.top_of_screen = $Boundaries/Top as Area2D
	ball.ghost_transparency = ghost_transparency
	ball.body_entered.connect(_on_ball_body_entered)
	$Balls.call_deferred("add_child", ball)
