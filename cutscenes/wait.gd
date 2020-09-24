extends Node

export var frames := 0
var manager: CutScene

func _ready():
	set_process(false)

func start(_manager: CutScene):
	manager = _manager
	set_process(true)

func end():
	manager.next()
	queue_free()

func _process(_dt):
	if frames <= 0:
		end()
	else:
		frames -= 1

func skip():
	end()

func should_wait_end() -> bool:
	return false
