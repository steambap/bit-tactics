extends Node

export(NodePath) var actor
export(bool) var waitEnd
var manager: CutScene

var _actor: Actor

func _ready():
	set_process(false)

func start(_manager: CutScene):
	manager = _manager
	
	_actor = get_node(actor)
	var map_pos = _actor.scene.get_terrain().world_to_map(_actor.position)
	_actor.position = _actor.scene.map_to_world_fixed(map_pos)
	
	if waitEnd:
		set_process(true)
	else:
		end()

func end():
	manager.next()
	queue_free()

func _process(_dt):
	var o = _actor.modulate.a
	
	if o >= 1.0:
		end()
	else:
		_actor.modulate.a = o + 0.1

func skip():
	_actor.modulate.a = 1.0
	end()

func should_wait_end() -> bool:
	return waitEnd
