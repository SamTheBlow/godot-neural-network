@icon("aibox.svg")
class_name BrainAI
extends AIBox
## AI brain
## 
## How to use:[br]
## Initialize this node using initialize_neural_network(),
## then use inputs_to_outputs() to get results!


# Neural network data
var weights: Array
var biases: Array

## Turning this on will print a bunch of stuff
var debug: bool = false


func number_of_inputs() -> int:
	return weights[0][0].size()


func number_of_outputs() -> int:
	return biases[-1].size()


## The input array must contain the correct number of inputs
func inputs_to_outputs(input_array: Array[float]) -> Array[float]:
	var values: Array[float] = input_array
	var input_values: int = input_array.size()
	
	if debug:
		print("Input: " + str(values))
	
	var number_of_transitions: int = weights.size()
	for i in number_of_transitions:
		var new_values: Array[float] = []
		var layer_size: int = biases[i].size()
		for value in layer_size:
			var new_value: float = 0.0
			for j in input_values:
				new_value += weights[i][value][j] * values[j]
			new_value += biases[i][value]
			new_values.append(relu(new_value))
		values = new_values
		input_values = new_values.size()
		
		if debug and (i < (weights.size() - 1)):
			print("Layer " + str(i + 1) + ": " + str(values))
	
	if debug:
		print("Output: " + str(values))
	
	return values


## The activation function
func relu(x: float) -> float:
	return maxf(0.0, x)


## Loads already existing data.
## The input array must contain the weights first, then the biases
func load_from_data(ai_data: Array) -> void:
	weights = ai_data[0]
	biases = ai_data[1]


# Use this to obtain the data!
func get_ai_data() -> Array:
	return [weights, biases]


# Functions for initializing the data
func initialize_neural_network(
		inputs: int,
		neuron_layers: Array[int],
		outputs: int
) -> void:
	weights = initialized_weights(inputs, neuron_layers, outputs, -1, 1)
	if debug:
		print("Weights: ", weights)
	biases = initialized_biases(neuron_layers, outputs, -1, 1)
	if debug:
		print("Biases: ", biases)


func initialized_weights(
		inputs: int,
		layers: Array[int],
		outputs: int,
		minimum: int,
		maximum: int
) -> Array:
	var array: Array = []
	var number_of_layers: int = layers.size()
	if number_of_layers == 0:
		array.append(randomly_filled_rectangle_array(outputs, inputs, minimum, maximum))
		return array
	array.append(randomly_filled_rectangle_array(layers[0], inputs, minimum, maximum))
	for i in number_of_layers - 1:
		array.append(randomly_filled_rectangle_array(layers[i + 1], layers[i], minimum, maximum))
	array.append(randomly_filled_rectangle_array(outputs, layers[number_of_layers - 1], minimum, maximum))
	return array


func initialized_biases(
		layers: Array[int],
		outputs: int,
		minimum: int,
		maximum: int
) -> Array:
	var array: Array = []
	var number_of_layers: int = layers.size()
	for i in number_of_layers:
		array.append(randomly_filled_array(layers[i], minimum, maximum))
	array.append(randomly_filled_array(outputs, minimum, maximum))
	return array


func randomly_filled_rectangle_array(
		lines: int,
		columns: int,
		minimum: int,
		maximum: int
) -> Array:
	var array: Array = []
	for i in lines:
		array.append(randomly_filled_array(columns, minimum, maximum))
	return array


func randomly_filled_array(
		array_size: int,
		minimum: int,
		maximum: int
) -> Array[float]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var array: Array[float] = []
	var delta: int = maximum - minimum
	for i in array_size:
		array.append(rng.randf() * delta + minimum)
	return array


func zero_filled_array(array_size: int) -> Array[float]:
	var array: Array[float] = []
	array.resize(array_size)
	array.fill(0.0)
	return array


## The cost function
func cost(
		generated_outputs: Array[float],
		expected_outputs: Array[float]
) -> float:
	# When making multiple tests, you take the average of all the costs
	# to learn how good your AI is at doing its job.
	# Of course, this only works if you know what the expected output is.
	
	# Returns the sum of the squares of the difference between each output.
	# This assumes both given arrays are the same size, which they should be.
	var cost_value: float = 0.0
	var number_of_outputs: int = generated_outputs.size()
	for i in number_of_outputs:
		cost_value += (generated_outputs[i] - expected_outputs[i]) ** 2
	return cost_value
