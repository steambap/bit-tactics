extends Node2D

var Marker = preload("res://nodes/move_marker.tscn")

onready var manager = get_parent()
var frame := 0
var time := 12
var actor: Actor

func _ready():
	for m in actor.get_movable_panels():
		add_marker_at(m)

	manager.get_cursor().activate(true)

func add_marker_at(pos: Vector2):
	var marker
	marker = Marker.instance()
	add_child(marker)
	marker.position = manager.map_to_world_fixed(pos)

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		finish()
	elif ev.is_action_pressed("ui_accept"):
		start()

func finish():
	manager.activate(true)
	queue_free()

func start():
	var cursor = manager.get_cursor()
	var terrain = manager.get_scene().get_terrain()
	var cursorPos = terrain.world_to_map(cursor.position)
	
	for m in get_children():
		if terrain.world_to_map(m.position) == cursorPos:
			actor.find_path_to(cursorPos)
			actor.state += 1
			finish()
			get_tree().set_input_as_handled()
			break
