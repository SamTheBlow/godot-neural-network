@icon("aibox_green.svg")
class_name NeuralNetworkUI
extends Control


@export var brain_data: Array = []:
	set = _set_brain_data


func _set_brain_data(data: Array) -> void:
	brain_data = data.duplicate(true)


func _draw() -> void:
	if brain_data.size() == 0:
		return
	
	var number_of_layers: int = brain_data[0].size() + 1
	for layer in number_of_layers:
		var layer_size: int = _get_layer_size(layer)
		for neuron_id in layer_size:
			var neuron_color: float = 0.5
			var neuron_pos: Vector2 = _get_neuron_pos(layer_size, layer, neuron_id)
			if layer > 0:
				var prev_layer_size: int = _get_layer_size(layer - 1)
				for i: int in brain_data[0][layer - 1][0].size():
					var weight: float = brain_data[0][layer - 1][neuron_id][i]
					var weight_color: Color
					if weight < 0:
						weight_color = Color(-weight, 0.0, 0.0)
					elif weight > 0:
						weight_color = Color(0.0, weight, 0.0)
					else:
						weight_color = Color(0.0, 0.0, 0.0)
					var from: Vector2 = _get_neuron_pos(prev_layer_size, layer - 1, i)
					draw_line(from, neuron_pos, weight_color)
			draw_circle(neuron_pos, 16, Color(neuron_color, neuron_color, neuron_color))


func _get_layer_size(layer: int) -> int:
	if layer == 0:
		return brain_data[0][0][0].size()
	else:
		return brain_data[0][layer - 1].size()


func _get_neuron_pos(layer_size: int, layer: int, neuron_id: int) -> Vector2:
	var number_of_layers: int = brain_data[0].size() + 1
	var rect: Vector2 = get_global_rect().size
	var pos_x: float = 1.0 / (number_of_layers + 1)
	var pos_y: float = 1.0 / (layer_size + 1)
	var neuron_x: float = rect.x * pos_x * (layer + 1)
	var neuron_y: float = rect.y * pos_y * (neuron_id + 1)
	return Vector2(neuron_x, neuron_y)
