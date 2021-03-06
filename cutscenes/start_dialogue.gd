extends Node

export var dialogue = ""
var manager: CutScene
var dialogueObj

func start(_manager: CutScene):
	print(get_name(), " has started!")
	manager = _manager

	var d = preload("res://nodes/dialogue_box.tscn")
	
	dialogueObj = d.instance()
	dialogueObj.start(self, dialogue)
	manager.scene.add_child(dialogueObj)

func skip():
	dialogueObj.queue_free()
	end()

func end():
	manager.next()
	queue_free()

func should_wait_end() -> bool:
	return true
