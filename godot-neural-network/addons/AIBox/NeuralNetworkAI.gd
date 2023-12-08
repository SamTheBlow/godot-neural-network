@icon("aibox.svg")
class_name NeuralNetworkAI
extends AIBox


## This variable lets the AI know how well it's doing.
## Increase it when the AI does something good, and
## decrease it when it does something bad!
var score: int = 0

var _brain: BrainAI


## Initialize the AI using a blueprint
func initialize(brain_blueprint: BrainBlueprint) -> void:
	_remove_brain()
	_brain = BrainAI.new()
	_brain.initialize_neural_network(brain_blueprint.number_of_inputs, brain_blueprint.neuron_layers, brain_blueprint.number_of_outputs)
	add_child(_brain)
	_brain.name = "Brain"


## Initialize the AI using existing data
func load_from_data(ai_data: Array) -> void:
	_remove_brain()
	_brain = BrainAI.new()
	_brain.load_from_data(ai_data)
	add_child(_brain)
	_brain.name = "Brain"


func get_ai_data() -> Array:
	if _brain:
		return _brain.get_ai_data()
	else:
		return []


## Takes inputs, gives outputs.
## Don't forget to initialize the AI beforehand!
func inputs_to_outputs(input_array: Array[float]) -> Array[float]:
	return _brain.inputs_to_outputs(input_array)


func _remove_brain() -> void:
	if _brain:
		remove_child(_brain)
		_brain.queue_free()
