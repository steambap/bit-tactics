extends Node

var manager

func start(_manager):
	manager = _manager
	var Battle = preload("res://nodes/battle_manager.tscn")
	manager.scene.add_child(Battle.instance())

func end():
	manager.next()
	queue_free()

func skip():
	end()

func should_wait_end():
	return true
