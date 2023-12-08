# Initialize this node using initialize_neural_network(),
# then use inputs_to_outputs() to get results!
extends AIBox
class_name BrainAI, "aibox.svg"

# Turning this on will print a bunch of stuff
var debug = false

### Mandatory functions -- all brains must have these essential functions
func number_of_inputs():
	return weights[0][0].size()

func number_of_outputs():
	return biases[-1].size()

# You may assume the user sent the correct number of inputs.
# If they did not, it's their problem!
func inputs_to_outputs(input_array) -> Array:
	var values = input_array
	var input_values = input_array.size()
	
	if debug:
		print("Input: " + String(values))
	
	var number_of_transitions = weights.size()
	for i in number_of_transitions:
		var new_values = []
		var layer_size = biases[i].size()
		for value in layer_size:
			var new_value = 0
			for input_value in input_values:
				new_value += weights[i][value][input_value] * values[input_value]
			new_value += biases[i][value]
			new_values.append(relu(new_value))
		values = new_values
		input_values = new_values.size()
		
		if debug && (i < (weights.size() - 1)):
			print("Layer " + String(i + 1) + ": " + String(values))
	
	if debug:
		print("Output: " + String(values))
	
	return values
###

### Necessary stuff for the neural network
var weights:Array
var biases:Array

# The "activation function"
func relu(x: float) -> float:
	return max(0.0, x)

# Use this to load already existing data!
# The input array should contain the weights first, then the biases
func load_from_data(ai_data):
	weights = ai_data[0]
	biases = ai_data[1]

# Use this to obtain the data!
func get_ai_data() -> Array:
	return [weights, biases]

# Functions for initializing the data
func initialize_neural_network(inputs: int, neuron_layers: PoolIntArray, outputs: int):
	weights = initialized_weights(inputs, neuron_layers, outputs, -1, 1)
	if debug:
		print("Weights: " + String(weights))
	biases = initialized_biases(neuron_layers, outputs, -1, 1)
	if debug:
		print("Biases: " + String(biases))

func initialized_weights(inputs, layers, outputs, minimum, maximum):
	var array = []
	var number_of_layers = layers.size()
	if (number_of_layers == 0):
		array.append(randomly_filled_rectangle_array(outputs, inputs, minimum, maximum))
		return array
	array.append(randomly_filled_rectangle_array(layers[0], inputs, minimum, maximum))
	for i in (number_of_layers - 1):
		array.append(randomly_filled_rectangle_array(layers[i + 1], layers[i], minimum, maximum))
	array.append(randomly_filled_rectangle_array(outputs, layers[number_of_layers - 1], minimum, maximum))
	return array

func initialized_biases(layers, outputs, minimum, maximum):
	var array = []
	var number_of_layers = layers.size()
	for i in number_of_layers:
		array.append(randomly_filled_array(layers[i], minimum, maximum))
	array.append(randomly_filled_array(outputs, minimum, maximum))
	return array

func randomly_filled_rectangle_array(lines, columns, minimum, maximum):
	var array = []
	for line in lines:
		array.append(randomly_filled_array(columns, minimum, maximum))
	return array

func randomly_filled_array(array_size, minimum, maximum):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var array = []
	var delta = maximum - minimum
	for i in array_size:
		array.append(rng.randf() * delta + minimum)
	return array

func zero_filled_array(array_size):
	var array = []
	array.resize(array_size)
	array.fill(0.0)
	return array
###

### Cost function
func cost(generated_outputs, expected_outputs) -> float:
	# When making multiple tests, you take the average of all the costs
	# to learn how good your AI is at doing its job.
	# Of course, this only works if you know what the expected output is.
	
	# Returns the sum of the squares of the difference between each output.
	# This assumes both given arrays are the same size, which they should be.
	var cost_value = 0.0
	var number_of_outputs = generated_outputs.size()
	for element in number_of_outputs:
		cost_value += pow(generated_outputs[element] - expected_outputs[element], 2)
	return cost_value
###
