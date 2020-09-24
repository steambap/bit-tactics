extends Node

var manager: CutScene
export(NodePath) var actor
export(Vector2) var position

func start(_manager: CutScene):
	manager = _manager
	
	get_node(actor).position = manager.scene.map_to_world_fixed(position)
	end()

func end():
	manager.next()
	queue_free()

func skip():
	end()

func should_wait_end():
	return false
