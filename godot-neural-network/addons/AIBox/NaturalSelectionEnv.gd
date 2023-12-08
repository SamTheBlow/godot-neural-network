@icon("aibox.svg")
class_name NaturalSelectionEnvironment
extends AIBox


## The percentage of brains to be killed in the natural selection process
@export_range(0, 100, 1) var kill_percentage: int = 90

const DATA_VERSION: int = 1
var generation: int = 0


func initialize(number_of_brains: int, brain_blueprint: BrainBlueprint) -> void:
	_delete_all_brains()
	var brains: Node = _brains_node()
	for i in number_of_brains:
		brains.add_child(_new_ai_from_blueprint(brain_blueprint))


func number_of_brains() -> int:
	return _brains_node().get_child_count()


func get_brain(index: int) -> NeuralNetworkAI:
	return _brains_node().get_child(index) as NeuralNetworkAI


## This should always be called at the start of each simulation
func start_simulation() -> void:
	generation += 1
	
	# Reset their score
	var brains: Array[Node] = _brains_node().get_children()
	for brain in brains:
		(brain as NeuralNetworkAI).score = 0


## This should always be called at the end of each simulation
func end_simulation() -> void:
	var brains: Node = _brains_node()
	
	# Sort the AI based on their score
	var ranked_ai: Array[Node] = brains.get_children()
	ranked_ai.sort_custom(_compare_ai_score)
	
	# Sort the AI in the scene tree
	var position: int = 0
	for i in ranked_ai:
		brains.move_child(i, position)
		position += 1


## Kills the worse AIs and makes copies of the better AIs
## (Calling this at the end of each simulation is not mandatory)
func apply_natural_selection() -> void:
	var brains: Node = _brains_node()
	
	var number_of_ai: int = number_of_brains()
	var number_of_ai_to_kill: int = number_of_ai * kill_percentage * 0.01
	var number_of_ai_alive: int = number_of_ai - number_of_ai_to_kill
	
	# Get rid of the worse ones
	for i in number_of_ai_to_kill:
		var child_to_kill: Node = brains.get_child(number_of_ai_alive)
		brains.remove_child(child_to_kill)
		child_to_kill.queue_free()
	
	# Make a bunch of randomly tweaked copies of the good ones
	for i in number_of_ai:
		var good_ai_data: Array = (brains.get_child(i % number_of_ai_alive) as NeuralNetworkAI).get_ai_data().duplicate(true)
		# Don't tweak the original ones!
		if i >= number_of_ai_alive:
			good_ai_data = _tweak_ai_data(good_ai_data, floorf(i * 0.1) * 0.1)
			#print(floor(i * 0.1) * 0.1)
			var new_ai: NeuralNetworkAI = _new_ai_from_data(good_ai_data)
			brains.add_child(new_ai)
		#print(good_ai_data[1][2][0])


## Save this AI's data to given file path
func save_to(file_path: String) -> void:
	var save_file := FileAccess.open(file_path, FileAccess.WRITE)
	
	# Save the data version
	save_file.store_line(JSON.new().stringify(DATA_VERSION))
	
	# Save the current generation
	save_file.store_line(JSON.new().stringify(generation))
	
	# Save the data
	var ai: Array[Node] = _brains_node().get_children()
	for node in ai:
		save_file.store_line(JSON.new().stringify((node as NeuralNetworkAI).get_ai_data()))
	
	save_file.close()


## Loads saved data from given file path
## Returns true if it worked, otherwise returns false
func load_from(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	
	var save_file := FileAccess.open(file_path, FileAccess.READ)
	
	# Look at the data version and abort if it doesn't match
	var json := JSON.new()
	json.parse(save_file.get_line())
	var file_version: int = json.data
	if file_version != DATA_VERSION:
		return false
	
	# Get the generation
	json.parse(save_file.get_line())
	generation = json.data
	
	# Get the data
	_delete_all_brains()
	var brains: Node = _brains_node()
	while save_file.get_position() < save_file.get_length():
		json.parse(save_file.get_line())
		var brain_data: Array = json.data
		brains.add_child(_new_ai_from_data(brain_data))
	
	save_file.close()
	return true


func _brains_node() -> Node:
	var brains: Node = get_node_or_null("Brains")
	if brains:
		return brains
	else:
		var new_node := Node.new()
		new_node.name = "Brains"
		add_child(new_node)
		return new_node


func _delete_all_brains() -> void:
	var brains: Node = _brains_node()
	var brains_children: Array[Node] = brains.get_children()
	for brain in brains_children:
		brains.remove_child(brain)
		brain.queue_free()


func _new_ai_from_blueprint(brain_blueprint: BrainBlueprint) -> NeuralNetworkAI:
	var ai := NeuralNetworkAI.new()
	ai.initialize(brain_blueprint)
	return ai


func _new_ai_from_data(ai_data: Array) -> NeuralNetworkAI:
	var ai := NeuralNetworkAI.new()
	ai.load_from_data(ai_data)
	return ai


func _compare_ai_score(a: NeuralNetworkAI, b: NeuralNetworkAI) -> bool:
	return a.score > b.score


func _tweak_ai_data(ai_data: Array, tweak_sensitivity: float) -> Array:
	for i in ai_data.size():
		if typeof(ai_data[i]) == TYPE_FLOAT:
			ai_data[i] = ai_data[i] + randf() * 2.0 * tweak_sensitivity - tweak_sensitivity
		elif typeof(ai_data[i]) > 18:
			# omg omg recursion im so smart look at this!!!
			ai_data[i] = _tweak_ai_data(ai_data[i], tweak_sensitivity)
	return ai_data
