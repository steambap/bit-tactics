extends Node

onready var scene = get_parent()

var hovered = null
var active = false
var turn = 0
var mstar

var enemyAI

signal has_found_an_actor

func _ready():
	
	scene.manager = self
	
	enemyAI = preload("res://nodes/battle_ai.gd").new()
	enemyAI.manager = self
	set_turn(0)
	add_child(enemyAI)
	
	for a in scene.get_actors():
		fix_position(a)
	
	fix_position(get_cursor())
	
	get_cursor().activate(false)
	
	$ui/BBBB/turn_panel/turn.set_text(str(get_turn_name(turn)))

	if turn == 0:
		$ui/BBBB/turn_panel/turn.set("custom_colors/font_color", Color(0.25, 0.25, 1.0, 1.0))
	else:
		$ui/BBBB/turn_panel/turn.set("custom_colors/font_color", Color(1.0, 0.25, 0.25, 1.0))
	
	set_process_input(true)

func set_turn(_turn):
	for actor in scene.get_actors():
		actor.set_gray(false)
		actor.state = 0
	
	turn = _turn
	$ui/BBBB/turn_panel/turn.set_text(str(get_turn_name(turn)))
	
	if turn == 0:
		$ui/BBBB/turn_panel/turn.set("custom_colors/font_color", Color(0.25, 0.25, 1.0, 1.0))
	else:
		$ui/BBBB/turn_panel/turn.set("custom_colors/font_color", Color(1.0, 0.25, 0.25, 1.0))
	
	print("Turn has changed to ", turn)
	
	get_cursor().activate(turn == 0)

func get_turn_name(_turn):
	if _turn == 0:
		return "Player"
	else:
		return "Enemy"

func _input(ev):
	if ev.is_action_pressed("ui_end"):

		if turn == 0:
			next_turn()
			get_tree().set_input_as_handled()

func get_scene():
	return scene

func get_cursor():
	return $cursor

func fix_position(node):
	var terrain = scene.get_terrain()
	
	var m = terrain.world_to_map(node.position)
	var w = terrain.map_to_world(m)
	
	node.position = w + Vector2(0, terrain.get_cell_size().y * 0.5)

func map_to_world_fixed(position):
	var terrain = scene.get_terrain()
	return terrain.map_to_world(position) + Vector2(0, terrain.get_cell_size().y * 0.5)

func _on_cursor_has_moved(sender):
	if active:
		print("UUUU")
		
		var cursorPosM = scene.get_terrain().world_to_map(sender.position)
		
		for actor in scene.get_actors():
			var actorPosM = scene.get_terrain().world_to_map(actor.position)
			
			if cursorPosM == actorPosM:
				print("The cursor has found an actor!")
				hovered = actor
				emit_signal("has_found_an_actor", hovered)
				
				return
		
		hovered = null
		emit_signal("has_found_an_actor", hovered)
	else:
		print("AAAA")

func _on_cursor_has_clicked(sender):
	if active && hovered:
		if hovered.state == 0:
			activate(false)
			sender.activate(false)
			var _moveState = preload("res://nodes/battle_state_move.tscn").instance()
			_moveState.actor = hovered
			add_child(_moveState)
		elif hovered.state == 1:
			activate(false)
			sender.activate(false)
			var _actState = preload("res://nodes/battle_state_act.tscn").instance()
			_actState.actor = hovered
			add_child(_actState)

func activate(enable):
	print("BattleManager state changed to ", enable, ".")
	active = enable

func _on_next_turn_pressed():
	next_turn()

func next_turn():
	set_turn(1)
	activate(false)
	$ui/BBBB/turn_panel/turn.set_text(str(get_turn_name(turn)))
	$ui/BBBB/turn_panel/turn.set("custom_colors/font_color", Color(1.0, 0.25, 0.25, 1.0))
	
	print("Turn has changed to ", turn)
	
	enemyAI.start()

func _on_title_intro_has_ended():
	activate(true)
	get_cursor().show()
	get_cursor().activate(true)
