extends Node

export var dialogue = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.name == self.name:
		test_dialogue()
	else:
		#normal scene, do nothing
		pass

func test_dialogue():
	var dialogue_box = load("res://nodes/dialogue_box.tscn");
	var dialogue_node = dialogue_box.instance()
	self.add_child(dialogue_node)
	dialogue_node.start(self, dialogue)

func end():
	print("test dialogue ended!")
