extends Node2D

var ai_env
var game_scene = preload("res://ExampleBallGame/GameScene.tscn")
onready var autonext = $CanvasLayer/Menu/CheckBoxes/AutoNext/CheckBox

# The simulation speed (must not be greater than 4)
export (float) var time_scale = 1.0

# The simulation time
export (int) var time = 10

# The number of players in the simulation
export (int) var number_of_ai = 100

func _ready():
	initialize_ai_environment()
	time_scale = min(4.0, time_scale)
	$CanvasLayer/Menu/EndOfSim.visible = false
	$CanvasLayer/SimulationUI.visible = false

func _process(_delta):
	$CanvasLayer/SimulationUI/Time.text = "Time left: " + String(floor($SimulationTimer.time_left))
	if autonext.pressed && Input.is_action_just_pressed("stop_autonextgen"):
		autonext.pressed = false
		$CanvasLayer/SimulationUI/Hint.visible = false

func start_simulation():
	var number_of_brains = ai_env.number_of_brains()
	for i in number_of_brains:
		var scene = game_scene.instance()
		
		# Show the first scene's interface
		if i == 0:
			scene.show_interface = true
			# Show its brain on the screen
			$CanvasLayer/SimulationUI/NeuralNetworkUI.brain_data = ai_env.get_brain(i).get_ai_data()
		
		# Set up the scene's AI
		scene.ai = ai_env.get_brain(i)
		
		# Move the scenes far away from each other
		scene.position.x = i * 10000
		
		$GameScenes.add_child(scene)
	
	Engine.time_scale = time_scale
	Engine.iterations_per_second = 60 * time_scale
	$SimulationTimer.wait_time = time
	$SimulationTimer.start()

func _on_NewSimulation_pressed():
	initialize_ai_environment()
	_on_NextGeneration_pressed()

func _on_NextGeneration_pressed():
	$CanvasLayer/Menu.visible = false
	$CanvasLayer/SimulationUI.visible = true
	$CanvasLayer/SimulationUI/Hint.visible = autonext.pressed
	ai_env.start_simulation()
	$CanvasLayer/SimulationUI/GenNumber.text = "Generation " + String(ai_env.generation)
	start_simulation()

# End of simulation
func _on_SimulationTimer_timeout():
	$CanvasLayer/SimulationUI.visible = false
	Engine.time_scale = 1.0
	Engine.iterations_per_second = 60
	
	# Get rid of the game scenes
	var game_scenes = $GameScenes.get_children()
	for child in game_scenes:
		child.queue_free()
	
	# Sort the AI based on their score, etc
	ai_env.end_simulation()
	
	var results = $CanvasLayer/Menu/EndOfSim/Results
	results.get_node("FirstPlace").text = "First place: " + String(ai_env.get_brain(0).score)
	results.get_node("SecondPlace").text = "Second place: " + String(ai_env.get_brain(1).score)
	results.get_node("ThirdPlace").text = "Third place: " + String(ai_env.get_brain(2).score)
	$CanvasLayer/Menu.visible = true
	$CanvasLayer/Menu/EndOfSim.visible = true
	if $CanvasLayer/Menu/CheckBoxes/AutoEvolve/CheckBox.pressed:
		ai_env.apply_natural_selection()
	if autonext.pressed:
		_on_NextGeneration_pressed()

func _on_Save_pressed():
	var save_name = formatted_save_name()
	if (save_name.is_valid_filename()):
		ai_env.save_to("user://" + save_name + ".save")
		print("Saved!")
	else:
		print("Can't save. Bad file name!")

func _on_Load_pressed():
	var save_name = formatted_save_name()
	if (save_name.is_valid_filename()):
		var success = ai_env.load_from("user://" + save_name + ".save")
		if success:
			print("Loaded successfully")
			$CanvasLayer/Menu/EndOfSim.visible = true
		else:
			print("Loading failed")
	else:
		print("Can't load. Bad file name!")

func formatted_save_name() -> String:
	# This is definitely not entirely fool-proof
	var save_name = $CanvasLayer/Menu/SaveName.text
	save_name = save_name.replace(" ", "")
	if save_name == "":
		save_name = "saved_ai"
	return save_name

# Creates (or resets) the AI environment
func initialize_ai_environment():
	if ai_env != null:
		remove_child(ai_env)
		ai_env.queue_free()
	ai_env = NaturalSelectionEnvironment.new()
	add_child(ai_env)
	ai_env.initialize(number_of_ai, $BrainBlueprint)
