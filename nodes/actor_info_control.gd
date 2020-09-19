extends Control

func update_info(actor):
	$actor_info/name.set_text(actor.actorName)

	#if it's an enemy, show its name red, otherwise, blue
	if actor.get_group() > 0:
		$actor_info/name.set("custom_colors/font_color", Color(1.0, 0.25, 0.25, 1.0))
	else:
		$actor_info/name.set("custom_colors/font_color", Color(0.25, 0.25, 1.0, 1.0))
		
	$actor_info/health/value.set_text(str(actor.HP, "/", actor.maxHP))

func _on_battle_has_found_an_actor(actor):
	if actor == null:
		$actor_info.hide()
	else:
		update_info(actor)
		$actor_info.show()
