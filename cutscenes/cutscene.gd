extends Node

onready var scene = get_parent()
var content = []

func _ready():
	set_process_input(true)
	start()

func start():
	for c in get_children():
		content.append(c)
	
	work()

func next():
	content.pop_front()
	work()

func work():
	if content.size() > 0:
		content.front().start(self)

func _input(ev):
	if ev.is_action_pressed("ui_cancel"):
		set_process_input(false)
		for c in get_children():
			c.skip()
