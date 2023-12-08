extends Node2D


## The simulation speed (must not be greater than 4)
@export_range(0.0001, 4.0, 1.0) var time_scale: float = 1.0

## How long the simulation goes, in seconds
@export var time: int = 10

## The number of players in the simulation
@export var number_of_ai: int = 100

## Turn this on if you want to play along with the AI!
@export var player_controlled: bool = false

var ai_env: NaturalSelectionEnvironment
var game_scene := preload("res://ExampleBallGame/GameScene.tscn") as PackedScene

@onready var menu := $CanvasLayer/Menu as Control
@onready var end_of_sim := $CanvasLayer/Menu/EndOfSim as Control
@onready var first_place := %FirstPlace as Label
@onready var second_place := %SecondPlace as Label
@onready var third_place := %ThirdPlace as Label
@onready var auto_next := $CanvasLayer/Menu/CheckBoxes/AutoNext/CheckBox as CheckBox
@onready var auto_evolve := $CanvasLayer/Menu/CheckBoxes/AutoEvolve/CheckBox as CheckBox
@onready var save_name_line_edit := $CanvasLayer/Menu/SaveName as LineEdit
@onready var simulation_ui := $CanvasLayer/SimulationUI as Control
@onready var neural_network_ui := $CanvasLayer/SimulationUI/NeuralNetworkUI as NeuralNetworkUI
@onready var time_label := $CanvasLayer/SimulationUI/Time as Label
@onready var gen_number_label := $CanvasLayer/SimulationUI/GenNumber as Label
@onready var hint_label := $CanvasLayer/SimulationUI/Hint as Label
@onready var simulation_timer := $SimulationTimer as Timer


func _ready() -> void:
	initialize_ai_environment()
	time_scale = minf(4.0, time_scale)
	end_of_sim.hide()
	simulation_ui.hide()


func _process(_delta: float) -> void:
	var time_left: int = floori(simulation_timer.time_left)
	time_label.text = "Time left: " + str(time_left)
	if auto_next.button_pressed and Input.is_action_just_pressed("stop_autonextgen"):
		auto_next.button_pressed = false
		hint_label.hide()


func _on_new_simulation_pressed() -> void:
	initialize_ai_environment()
	_on_next_generation_pressed()


func _on_next_generation_pressed() -> void:
	menu.hide()
	simulation_ui.show()
	hint_label.visible = auto_next.button_pressed
	ai_env.start_simulation()
	gen_number_label.text = "Generation " + str(ai_env.generation)
	start_simulation()


func _on_simulation_timer_timeout() -> void:
	simulation_ui.hide()
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 60
	
	# Get rid of the game scenes
	var game_scenes: Array[Node] = $GameScenes.get_children()
	for child in game_scenes:
		child.queue_free()
	
	# Sort the AI based on their score, etc
	ai_env.end_simulation()
	
	first_place.text = "First place: " + str(ai_env.get_brain(0).score)
	second_place.text = "Second place: " + str(ai_env.get_brain(1).score)
	third_place.text = "Third place: " + str(ai_env.get_brain(2).score)
	menu.show()
	end_of_sim.show()
	if auto_evolve.button_pressed:
		ai_env.apply_natural_selection()
	if auto_next.button_pressed:
		_on_next_generation_pressed()


func _on_save_pressed() -> void:
	var save_name: String = formatted_save_name()
	if save_name.is_valid_filename():
		ai_env.save_to("user://" + save_name + ".save")
		print("Saved!")
	else:
		print("Can't save. Bad file name!")


func _on_load_pressed() -> void:
	var save_name: String = formatted_save_name()
	if save_name.is_valid_filename():
		var success: bool = ai_env.load_from("user://" + save_name + ".save")
		if success:
			print("Loaded successfully")
			end_of_sim.show()
		else:
			print("Loading failed")
	else:
		print("Can't load. Bad file name!")


## Creates (or resets) the AI environment
func initialize_ai_environment() -> void:
	if ai_env:
		remove_child(ai_env)
		ai_env.queue_free()
	ai_env = NaturalSelectionEnvironment.new()
	add_child(ai_env)
	ai_env.initialize(number_of_ai, $BrainBlueprint as BrainBlueprint)


func start_simulation() -> void:
	var number_of_brains: int = ai_env.number_of_brains()
	for i in number_of_brains:
		var scene := game_scene.instantiate() as Game
		var brain: NeuralNetworkAI = ai_env.get_brain(i)
		
		# Show the first scene's interface
		if i == 0:
			scene.show_interface = true
			# Show its brain on the screen
			neural_network_ui.brain_data = brain.get_ai_data()
		
		scene.player_controlled = player_controlled
		
		# Set up the scene's AI
		scene.ai = brain
		
		# Move the scenes far away from each other
		scene.position.x = i * 10000
		
		$GameScenes.add_child(scene)
	
	Engine.time_scale = time_scale
	Engine.physics_ticks_per_second = int(60.0 * time_scale)
	simulation_timer.wait_time = time
	simulation_timer.start()


func formatted_save_name() -> String:
	# This is definitely not entirely fool-proof
	var save_name: String = save_name_line_edit.text
	save_name = save_name.replace(" ", "")
	if save_name == "":
		save_name = "saved_ai"
	return save_name
