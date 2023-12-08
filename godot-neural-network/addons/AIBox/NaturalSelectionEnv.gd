extends AIBox
class_name NaturalSelectionEnvironment, "aibox.svg"

## The percentage of brains to be killed in the natural selection process
export (int, 100) var kill_percentage = 90

## Do not set these variables!!!
var data_version = 1
var generation = 0

func initialize(number_of_brains: int, brain_blueprint: Node):
	_delete_all_brains()
	var brains = _brains_node()
	for i in number_of_brains:
		brains.add_child(_new_ai_from_blueprint(brain_blueprint))

func number_of_brains() -> int:
	return _brains_node().get_child_count()

func get_brain(index) -> Node:
	return _brains_node().get_child(index)

# This should always be called at the start of each simulation
func start_simulation():
	generation += 1
	
	# Reset their score
	var brains = _brains_node().get_children()
	for i in brains:
		i.score = 0

# This should always be called at the end of each simulation
func end_simulation():
	var brains = _brains_node()
	
	# Sort the AI based on their score
	var ranked_ai = brains.get_children()
	ranked_ai.sort_custom(self, "_compare_ai_score")
	
	# Sort the AI in the scene tree
	var position = 0
	for i in ranked_ai:
		brains.move_child(i, position)
		position += 1

# Kill the worse AIs and make copies of the better AIs!
# (Calling this at the end of each simulation is not mandatory)
func apply_natural_selection():
	var brains = _brains_node()
	
	var number_of_ai = number_of_brains()
	var number_of_ai_to_kill: int = number_of_ai * kill_percentage * 0.01
	var number_of_ai_alive = number_of_ai - number_of_ai_to_kill
	
	# Get rid of the worse ones
	for i in number_of_ai_to_kill:
		var child_to_kill = brains.get_child(number_of_ai_alive)
		brains.remove_child(child_to_kill)
		child_to_kill.queue_free()
	
	# Make a bunch of randomly tweaked copies of the good ones
	for i in number_of_ai:
		var good_ai_data = brains.get_child(i % number_of_ai_alive).get_ai_data().duplicate(true)
		# Don't tweak the original ones!
		if i >= number_of_ai_alive:
			good_ai_data = _tweak_ai_data(good_ai_data, floor(i * 0.1) * 0.1)
			#print(floor(i * 0.1) * 0.1)
			var new_ai = _new_ai_from_data(good_ai_data)
			brains.add_child(new_ai)
		#print(good_ai_data[1][2][0])

# Use this to save your data!
func save_to(path):
	var save_file = File.new()
	save_file.open(path, File.WRITE)
	
	# Save the data version
	save_file.store_line(to_json(data_version))
	
	# Save the current generation
	save_file.store_line(to_json(generation))
	
	# Save the data
	var ai = _brains_node().get_children()
	for i in ai:
		save_file.store_line(to_json(i.get_ai_data()))
	save_file.close()

# Use this load your saved data!
# Returns true if it worked, otherwise returns false
func load_from(path) -> bool:
	var save_file = File.new()
	if save_file.file_exists(path) == false:
		return false
	save_file.open(path, File.READ)
	
	# Look at the data version and abort if it doesn't match
	var file_version = parse_json(save_file.get_line())
	if file_version != data_version:
		return false
	
	# Get the generation
	generation = parse_json(save_file.get_line())
	
	# Get the data
	_delete_all_brains()
	var brains = _brains_node()
	while save_file.get_position() < save_file.get_len():
		var brain_data = parse_json(save_file.get_line())
		brains.add_child(_new_ai_from_data(brain_data))
	
	save_file.close()
	return true

### Private functions!! Not meant to be used..!!
func _brains_node() -> Node:
	var brains = get_node_or_null("Brains")
	if brains == null:
		var new_node = Node.new()
		new_node.name = "Brains"
		add_child(new_node)
		return new_node
	else:
		return brains

func _delete_all_brains():
	var brains = _brains_node()
	var brains_children = brains.get_children()
	for i in brains_children:
		brains.remove_child(i)
		i.queue_free()

func _new_ai_from_blueprint(brain_blueprint) -> Node:
	var ai = NeuralNetworkAI.new()
	ai.initialize(brain_blueprint)
	return ai

func _new_ai_from_data(ai_data) -> Node:
	var ai = NeuralNetworkAI.new()
	ai.load_from_data(ai_data)
	return ai

func _compare_ai_score(a, b):
	return a.score > b.score

func _tweak_ai_data(ai_data, tweak_sensitivity) -> Array:
	var array = ai_data
	for i in array.size():
		if typeof(array[i]) == TYPE_REAL:
			array[i] = array[i] + randf() * 2 * tweak_sensitivity - tweak_sensitivity
		elif typeof(array[i]) > 18:
			# omg omg recursion im so smart look at this!!!
			array[i] = _tweak_ai_data(array[i], tweak_sensitivity)
	return array
