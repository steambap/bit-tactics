extends Node

export(NodePath) var actor
export(Vector2) var position
export(bool) var shouldWaitArrival

var manager: CutScene
var actorNode: Actor

func _ready():
	set_process(false)

func start(_manager: CutScene):
	manager = _manager

	actorNode = get_node(actor)
	actorNode.find_path_to(position)

	if shouldWaitArrival:
		set_process(true)
	else:
		end()

func skip():
	actorNode.position = manager.scene.map_to_world_fixed(position)
	actorNode.path.resize(0)
	end()

func end():
	manager.next()

func _process(_dt):
	if !actorNode.should_move():
		if shouldWaitArrival:
			end()
		queue_free()

func should_wait_end() -> bool:
	return shouldWaitArrival
