extends CanvasLayer

var speaker = []
var speech = []
var dialogueList = {}

var manager

func _init():
	dialogueList["01_castle"] = preload("res://scenes/01_castle_intro_dialogue.tscn")

func start(_manager, _dialogue):
	
	set_process_input(true)
	
	manager = _manager
	
	var dialogue = dialogueList[_dialogue].instance()
	
	for i in dialogue.get_children():
		speaker.append(i.speaker)
		speech.append(i.speech)
	
	$EBBB/box/speaker.set_text(speaker.front())
	$EBBB/box/speech.set_text(speech.front())

func _input(ev):
	if ev.is_action_pressed("ui_accept"):
		step()

func step():
	speaker.pop_front()
	speech.pop_front()
	
	if speaker.size() == 0:
		end()
	else:
		$EBBB/box/speaker.set_text(speaker.front())
		$EBBB/box/speech.set_text(speech.front())

func end():
	queue_free()
	
	if manager:
		manager.end()

func skip():
	end()
