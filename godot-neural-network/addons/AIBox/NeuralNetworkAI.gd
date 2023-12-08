extends AIBox
class_name NeuralNetworkAI, "aibox.svg"

# This variable lets the AI know how well it's doing.
# Increase it when the AI does something good, and
# decrease it when it does something bad!
var score = 0

# Initialize the AI using a blueprint
func initialize(brain_blueprint):
	_remove_brain()
	var brain = BrainAI.new()
	brain.initialize_neural_network(brain_blueprint.number_of_inputs, brain_blueprint.neuron_layers, brain_blueprint.number_of_outputs)
	add_child(brain)
	brain.name = "Brain"

# Initialize the AI using existing data
func load_from_data(ai_data):
	_remove_brain()
	var brain = BrainAI.new()
	brain.load_from_data(ai_data)
	add_child(brain)
	brain.name = "Brain"

# Use this to get the AI data!
func get_ai_data() -> Array:
	var brain = get_node_or_null("Brain")
	if brain != null:
		return brain.get_ai_data()
	else:
		return []

# Takes inputs, gives outputs.
# Don't forget to initialize the AI beforehand!
func inputs_to_outputs(input_array: PoolRealArray) -> PoolRealArray:
	return get_node("Brain").inputs_to_outputs(input_array)

### Private functions!! Not meant to be used!!
func _remove_brain():
	var brain = get_node_or_null("Brain")
	if  brain != null:
		remove_child(brain)
		brain.queue_free()
