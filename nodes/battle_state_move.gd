extends Node2D

var Marker = preload("res://nodes/move_marker.tscn")

onready var manager = get_parent()
var frame = 0
var time = 12
var actor

func _ready():
	print("Move state started, my actor: ", actor.actorName, ". Move: ", actor.move)
	
	var terrain = manager.get_scene().get_terrain()
	var actors = manager.scene.get_actors()
	
	for a in actors:
		if a.group != actor.group:
			manager.get_scene().get_mstar().forbidv(terrain.world_to_map(a.position))
	
	for m in actor.get_movable_panels():
		add_marker_at(m)
	
	for m in get_children():
		for a in actors:
			if a != actor:
				if terrain.world_to_map(m.position) == terrain.world_to_map(a.position):
					m.queue_free()
	
	for a in actors:
		if a.group != actor.group:
			manager.scene.get_mstar().freecv(terrain.world_to_map(a.position))
	
	manager.get_cursor().activate(true)
	set_process_input(true)
	set_process(true)

func add_marker_at(pos):
	var marker
	marker = Marker.instance()
	add_child(marker)
	marker.position = manager.map_to_world_fixed(pos)

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		finish()
	elif ev.is_action_pressed("ui_accept"):
		#print("AIUSHDIA")
		
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

func is_free(list, terrain, source):
	for A in list:
		var pos = terrain.world_to_map(A.position)
		if pos == source:
			return false
	return true
