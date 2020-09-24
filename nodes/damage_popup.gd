class_name DamagePopup
extends Node2D

var goalY: Vector2
var timer := 45
var toDie := false

func _ready():
	goalY = self.global_position - Vector2(0, 12)

func _process(_dt):
	if !toDie:
		var motion = goalY - self.global_position
		translate(motion / 8)
		
		if motion.y < 1:
			timer -= 1
			
			if timer <= 0:
				toDie = true
	else:
		translate(-Vector2(0, 0.5))
		var o = self.modulate.a
		self.modulate.a = o - 0.05
		
		if o <= 0:
			queue_free()
