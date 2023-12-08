class_name Ball
extends RigidBody2D


var cursor_scene := preload("res://ExampleBallGame/BallCursor.tscn") as PackedScene

# To be set up manually by the node building this ball
var cursor_canvas: CanvasLayer
var top_of_screen: Area2D
var ghost_transparency: float
#

@onready var cursor := cursor_scene.instantiate() as Control
@onready var ghost := $Ghost as Sprite2D


func _ready() -> void:
	ghost.modulate.a = ghost_transparency
	cursor_canvas.add_child(cursor)
	top_of_screen.body_entered.connect(_on_top_body_entered)
	top_of_screen.body_exited.connect(_on_top_body_exited)


func _process(_delta: float) -> void:
	cursor.position = Vector2(global_position.x - 40.0, 80.0)
	ghost.global_position = position


func _exit_tree() -> void:
	cursor.queue_free()


func _on_top_body_entered(_body: Node2D) -> void:
	if global_position.y >= -200:
		cursor.show()


func _on_top_body_exited(_body: Node2D) -> void:
	if global_position.y >= 0:
		cursor.hide()
