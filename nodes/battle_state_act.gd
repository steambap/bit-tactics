extends Node2D

var Marker = preload("res://nodes/move_marker.tscn")

onready var manager = get_parent()
var frame = 0
var time = 12
var actor

func _ready():
	print("ACT state started, my actor: ", actor.actorName, ". Move: ", actor.move)
	
	var terrain = manager.get_scene().get_terrain()
	var source = terrain.world_to_map(actor.position)
	
	for x in range(max(1, source.x - actor.attackRange), source.x + actor.attackRange + 1):
		for y in range(max(1, source.y - actor.attackRange), source.y + actor.attackRange + 1):
			var pos = Vector2(x, y)
			
			if pos == source:
				continue
			
			if terrain.get_cell(x, y) < 0:
				continue
			
			var difference = pos - source
			if abs(difference.x) + abs(difference.y) > actor.attackRange:
				continue

			add_marker_at(pos)
	
	manager.get_cursor().activate(true)
	set_process_input(true)
	set_process(true)

func add_marker_at(pos):
	var marker
	marker = Marker.instance()
	add_child(marker)
	marker.position = manager.map_to_world_fixed(pos)
	marker.set_frame(1)

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		finish()
	elif ev.is_action_pressed("ui_accept"):
		#print("AIUSHDIA")
		
		start()

func finish():
	manager.get_cursor().position = actor.position
	manager.activate(true)
	queue_free()

func start():
	var terrain = manager.get_scene().get_terrain()
	var cursor = manager.get_cursor()
	var cursorPos = terrain.world_to_map(cursor.position)
	
	for m in get_children():
		
		var mp = terrain.world_to_map(m.position)
		
		if mp == cursorPos:
			for a in manager.scene.get_actors():
				if terrain.world_to_map(a.position) == cursorPos:
					actor.set_gray(true)
					actor.state += 1
					
					actor.attack(a)
					
					finish()
					
					get_tree().set_input_as_handled()
					return

func is_free(list, terrain, source):
	for A in list:
		var pos = terrain.world_to_map(A.position)
		if pos == source:
			return false
	return true
