extends Node


@export var test_scene: PackedScene


func _ready() -> void:
	var start_time: int
	var dummy_variable: String = "hello"
	var brain: TestNode
	var count: int = 10000
	
	print(str(count) + " nodes:")
	start_time = Time.get_ticks_msec()
	for i in count:
		brain = test_scene.instantiate() as TestNode
		brain.dummy_variable = dummy_variable
		add_child(brain)
	var children: Array[Node] = get_children()
	for child in children:
		child.queue_free()
	print(str(Time.get_ticks_msec() - start_time) + " ms")
	
	var objects: Array = []
	var dummy_array: Array = []
	print(str(count) + " arrays:")
	start_time = Time.get_ticks_msec()
	for i in count:
		dummy_array = [dummy_variable]
		objects.append(dummy_array)
	for i in count:
		objects.remove_at(0)
	print(str(Time.get_ticks_msec() - start_time) + " ms")
	print("Done")
