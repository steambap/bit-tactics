extends Sprite

export var actorName = "Unnamed"
export var group = 0
export var move = 5
export var attackRange = 1

export var attackPower = 24

export var maxHP = 100
export var HP = 100

var path = []

var state = 0

var myManagerAI = null
var waitAI = 30
var isAI = false

var animIndex = 0.0
var animAngle = 0

var aiActionEndTimer = -1

var isWaitingForNextStepAI = false
var nextStepTimerAI = 0

onready var scene = get_tree().current_scene

func should_move():
	return path.size() > 0

func _process(_dt):
	if isAI && isWaitingForNextStepAI:
		if nextStepTimerAI <= 0:
			isWaitingForNextStepAI = false
			ai_make_decision(myManagerAI)
		else:
			nextStepTimerAI -= 1
	
	if should_move():
		var motion = path[0] - self.position
		
		if motion.length_squared() < 0.5 * 0.5:
			self.position = path[0]
				
			if path.size() > 1:
				look_at(path[1])
			else:
				animIndex = 0
				set_frame(animAngle * 4 + floor(animIndex))
			
			path.pop_front()
			
			if isAI && path.size() == 0:
				ai_wait_and_step(15)
		else:
			if animIndex < 3.0 - 0.2:
				animIndex += 0.2
			else:
				animIndex = 0.0
			set_frame(animAngle * 4 + floor(animIndex))
			
			print("FRAME: ", animAngle * 4 + floor(animIndex))
				
			translate(motion.normalized() * 0.5)

func ai_wait_and_step(time):
	nextStepTimerAI = time
	isWaitingForNextStepAI = true

func ai_make_decision(_manager):
	isAI = true
	myManagerAI = _manager
	
	if state == 0:
		print("AI SHOULD MOVE")
		ai_move()
		state += 1
	elif state == 1:
		print("AI SHOULD ACT")
		var a = ai_act()
		
		if a:
			state += 1
		else:
			print("AI SHOULD SHOULD ABORT")
			set_gray(true)
			state += 1
	else:
		print("AI SHOULD SHOULD END")
		set_gray(true)
		isAI = false
		myManagerAI.make_decision()
	

func set_gray(enable):
	if enable:
		self.modulate.v = 0.5
	else:
		self.modulate.v = 1

#THIS WILL RETURN THE PANELS (VECTOR2'S) THIS ACTOR CAN MOVE TO!
func get_targettable_panels():
	#its position in the map
	var source = get_map_position()
	#var actors = scene.get_actors()
	var targettable = []
	
	for x in range(max(1, source.x - attackRange), source.x + attackRange + 1):
		for y in range(max(1, source.y - attackRange), source.y + attackRange + 1):
			#getting the position
			var pos = Vector2(x, y)
			
			if pos == source:
				continue

			var difference = pos - source
			if abs(difference.x) + abs(difference.y) > attackRange:
				continue

			targettable.append(pos)
	
	return targettable


#THIS WILL RETURN THE PANELS (VECTOR2'S) THIS ACTOR CAN MOVE TO!
func get_movable_panels():
	#its position in the map
	var source = get_map_position()#scene.get_terrain().world_to_map(get_pos())
	var actors = scene.get_actors()
	var actorsPos = []
	var movable = []

	lock_enemy_cells()
	#first of all, let's forbid enemy cells (allies' stay free as they can move through them)
	for actor in actors:
		#if self, ignore (since an unit can move to its own panel)
		if actor == self:
			continue

		#let's keep track of actors positions to use later!
		var ap = actor.get_map_position()#scene.get_terrain().world_to_map(actor.get_pos())
		actorsPos.append(ap)

	for x in range(max(1, source.x - move), source.x + move + 1):
		for y in range(max(1, source.y - move), source.y + move + 1):
			#getting the position
			var pos = Vector2(x, y)
			
			#if the panel is occupied by an actor
			var isOccupied = false
			for p in actorsPos:
				if pos == p:
					isOccupied = true
					break
			
			if isOccupied:
				continue
			
			#if it's not close enough
			var difference = pos - source
			if abs(difference.x) + abs(difference.y) > move:
				continue
			
			#if nothing works, I have to use A* to find out
			var pathV = scene.get_mstar().find_path_v(source, pos)
			if pathV.size() < 1 || pathV.size() > move:
				continue
			
			#seems like it's available ;_;
			movable.append(pos)

	unlock_enemy_cells()

	return movable

func get_move():
	return move

func get_group():
	return group

func get_nearest_foe():
	
	var nearest = null
	var nearestDistance = 0
	
	var source = get_map_position()
	
	for foe in get_foes():
		var pos = foe.get_map_position()
		var pathV = scene.get_mstar().find_path_v(source, pos)
		
		if pathV.size() < nearestDistance:
			nearestDistance = pathV.size()
			nearest = foe
	
	return nearest

func get_nearest_foe_and_info():
	var nearest = null
	var distance = 999
	var n = {}
	
	#get my position in the map ("grid")
	var source = get_map_position()
	
	#loop through the foes
	for foe in get_foes():
		#get its position and find a path to it
		var pos = foe.get_map_position()
		var pathV = scene.get_mstar().find_path_v(source, pos)
		
		#if nearest hasn't been set or the distance to THIS guy is lower than the current nearest
		if pathV.size() <= distance:
			#this is the new nearest
			distance = path.size()
			nearest = foe
			n["path"] = pathV
			n["actor"] = nearest
			n["distance"] = distance - 1
	
	#then we return the dictionary with the nearest and some useful data!
	return n


func get_map_position():
	return scene.get_terrain().world_to_map(self.position)

func get_foes():
	
	var _f = []
	
	for actor in scene.get_actors():
		if actor.group != group:
			_f.append(actor)
	
	return _f


func ai_move():
	#get the nearest enemy
	var nearest = get_nearest_foe_and_info()
	print("AI:", actorName, " just found ", nearest["actor"].name, " to be the nearest. Distance: ", nearest["distance"])
	
	#invert the path to it because we will be checking from backwards
	nearest["path"].invert()
	var movable = get_movable_panels()
	
	#loop through the path to the nearest foe
	for i in nearest["path"]:
		#if i can move to that panel, do so
		if can_move_to(movable, i):
			print("AI: ", actorName, " can move to ", i)
			find_path_to(i)
			#set_pos(scene.map_to_world_fixed(i))
			break
		else:
			#if not, keep trying!
			print("AI: ", actorName, " can NOT move to ", i, ", move on.")

func ai_act():
	var nearest = get_nearest_foe_and_info()
	
	isWaitingForNextStepAI = true
	
	if can_attack(get_targettable_panels(), nearest["actor"]):
		attack(nearest["actor"])
		nextStepTimerAI = 30
		return true
	else:
		nextStepTimerAI = 5
		return false

func attack(target):
	var dam = preload("res://nodes/damage_popup.tscn").instance()
	dam.position = target.position + Vector2(0, -10)
	get_parent().add_child(dam)
	target.HP -= attackPower
	dam.get_node("value").set_text(str(attackPower))
	
	if target.HP <= 0:
		target.queue_free()

#TO DETERMINE IF AN ACTOR CAN MOVE TO A PANEL
func can_move_to(movablePanels, pos):
	for m in movablePanels:
		if m == pos:
			return true
	
	return false

func can_attack(targettablePanels, target):
	for m in targettablePanels:
		if m == target.get_map_position():
			return true
	
	return false

func lock_enemy_cells():
	for _actor in scene.get_actors():
		if _actor.get_group() != group:
			scene.get_mstar().disable_point(_actor.get_map_position())

func unlock_enemy_cells():
	for _actor in scene.get_actors():
		if _actor.get_group() != group:
			scene.get_mstar().enable_point(_actor.get_map_position())

func find_path_to(position):
	lock_enemy_cells()
	var _path = scene.get_mstar().find_path_v(scene.get_terrain().world_to_map(self.position), position)
	unlock_enemy_cells()

	for p in _path:
		path.append(scene.map_to_world_fixed(p))
	
	if path.size() > 1:
		look_at(path[1])

func look_at(position):
	var vector = position - self.position
	var angle = get_correct_angle(vector.angle())

	animAngle = get_angle_side(angle)
	
	print("looking at angle: ", angle, " --> ", get_angle_string(angle))

func get_angle_string(degrees):
	if abs(115 - degrees) < 20:
		return "DOWN"
	if abs(245 - degrees) < 20:
		return "RIGHT"
	if abs(295 - degrees) < 20:
		return "UP"
	if abs(65 - degrees) < 20:
		return "LEFT"
	
	return "---"

func get_angle_side(degrees):
	if abs(115 - degrees) < 20:
		return 1
	if abs(245 - degrees) < 20:
		return 0
	if abs(295 - degrees) < 20:
		return 2
	if abs(65 - degrees) < 20:
		return 3
	
	return 0

func get_correct_angle(angle):
	return rad2deg(angle) + 180.0
