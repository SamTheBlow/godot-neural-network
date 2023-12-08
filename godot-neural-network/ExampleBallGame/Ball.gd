extends RigidBody2D

var cursor_scene = preload("res://ExampleBallGame/BallCursor.tscn")
var cursor

# To be set up manually by the node building this ball
var cursor_canvas
var top_of_screen
var ghost_transparency

func _ready():
	$Ghost.modulate.a = ghost_transparency
	cursor = cursor_scene.instance()
	cursor_canvas.add_child(cursor)
	top_of_screen.connect("body_entered", self, "_on_Top_body_entered")
	top_of_screen.connect("body_exited", self, "_on_Top_body_exited")

func _process(_delta):
	cursor.rect_position.x = global_position.x - 40
	cursor.rect_position.y = 80
	$Ghost.global_position = position

func _exit_tree():
	cursor.queue_free()

func _on_Top_body_entered(_body):
	if global_position.y >= -200:
		cursor.visible = true

func _on_Top_body_exited(_body):
	if global_position.y >= 0:
		cursor.visible = false
