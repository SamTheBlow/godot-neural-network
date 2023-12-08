extends Node

export (PackedScene) var test_scene

func _ready():
	var start_time
	var dummy_variable = "hello"
	var brain
	var objects = []
	var count = 10000
	
	print(String(count) + " nodes:")
	start_time = OS.get_ticks_msec()
	for i in count:
		brain = test_scene.instance()
		brain.dummy_variable = dummy_variable
		add_child(brain)
	var children = get_children()
	for child in children:
		child.queue_free()
	print(String(OS.get_ticks_msec() - start_time) + " ms")
	
	print(String(count) + " arrays:")
	start_time = OS.get_ticks_msec()
	for i in count:
		brain = [dummy_variable]
		objects.append(brain)
	for i in count:
		objects.remove(0)
	print(String(OS.get_ticks_msec() - start_time) + " ms")
	print("Done")
