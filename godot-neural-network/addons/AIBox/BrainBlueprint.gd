extends AIBox
class_name BrainBlueprint, "aibox.svg"

## The number of inputs
export (int) var number_of_inputs = 1
## The number of neuron layers, and the number of neurons in each layer
export (Array, int) var neuron_layers = []
## The number of outputs
export (int) var number_of_outputs = 1
