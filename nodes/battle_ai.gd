class_name BattleAI
extends Node
var manager # BattleManager
var friends: Array
var foes: Array
var available: Array
var timer := 30
var endTimer := 30
func start():
	friends = get_friends()
	available = [] + friends
	foes = get_foes()
	
	print("Friends: ", friends.size())
	print("Foes: ", foes.size())
	
	make_decision()
	#set_process(true)

func make_decision():
	foes = get_foes()
	
	if foes.size() == 0:
		set_process(true)
		endTimer = 30
		return
	
	#available = get_available_friends()
	if available.size() <= 0:
		set_process(true)
		endTimer = 30
		return
	
	available.back().ai_make_decision(self)
	available.pop_back()

func _process(_dt):
	if endTimer <= 0:
		manager.activate(true)
		manager.set_turn(0)
		set_process(false)
		print("X MARKS THE SPOT ------------------------")
	else:
		endTimer -= 1

func get_friends() -> Array:
	
	var _f = []
	
	for actor in manager.scene.get_actors():
		if actor.group == 1:
			_f.append(actor)
	
	return _f

func get_foes() -> Array:
	
	var _f = []
	
	for actor in manager.scene.get_actors():
		if actor.group != 1:
			_f.append(actor)
	
	return _f

func _ready():
  set_process(false)
