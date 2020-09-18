extends Node

var manager

func start(_manager):
	manager = _manager
	var Battle = preload("res://nodes/battle_manager.tscn").instance()
	manager.scene.add_child(Battle)

func end():
	print(get_name(), " has ended!")
	manager.contentNow.pop_front()
	manager.content.pop_front()
	manager.work()
	queue_free()

func skip():
	end()

func should_wait_end():
	return true
