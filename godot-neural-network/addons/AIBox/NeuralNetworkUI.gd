extends Control
class_name NeuralNetworkUI, "aibox_green.svg"

export (Array) var brain_data = [] setget _set_brain_data, _get_brain_data

func _set_brain_data(data: Array):
	brain_data = data.duplicate(true)

func _get_brain_data() -> Array:
	return brain_data

# Override
func _draw():
	if brain_data.size() == 0:
		return
	
	var number_of_layers = brain_data[0].size() + 1
	for layer in number_of_layers:
		var layer_size = _get_layer_size(layer)
		for neuron_id in layer_size:
			var neuron_color = 0.5
			var neuron_pos = _get_neuron_pos(layer_size, layer, neuron_id)
			if layer > 0:
				var prev_layer_size = _get_layer_size(layer - 1)
				for i in brain_data[0][layer - 1][0].size():
					var weight = brain_data[0][layer - 1][neuron_id][i]
					var weight_color
					if weight < 0:
						weight_color = Color(-weight, 0, 0, 1)
					elif weight > 0:
						weight_color = Color(0, weight, 0, 1)
					else:
						weight_color = Color(0, 0, 0, 1)
					var from = _get_neuron_pos(prev_layer_size, layer - 1, i)
					draw_line(from, neuron_pos, weight_color)
			draw_circle(neuron_pos, 16, Color(neuron_color, neuron_color, neuron_color, 1))

func _get_layer_size(layer) -> int:
	if layer == 0:
		return brain_data[0][0][0].size()
	else:
		return brain_data[0][layer - 1].size()

func _get_neuron_pos(layer_size, layer, neuron_id) -> Vector2:
	var number_of_layers = brain_data[0].size() + 1
	var rect = get_global_rect().size
	var pos_x = 1.0 / float(number_of_layers + 1)
	var pos_y = 1.0 / float(layer_size + 1)
	var neuron_x = rect.x * pos_x * (layer + 1)
	var neuron_y = rect.y * pos_y * (neuron_id + 1)
	return Vector2(neuron_x, neuron_y)
