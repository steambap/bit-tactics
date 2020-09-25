class_name Scene
extends Node

var mstar: MStar

var manager: BattleManager

func _ready():
	set_process(true)

	mstar = preload("res://scripts/mstar.gd").new(50, 50)
	mstar.block_based_on_tilemap(get_terrain_collider())

func get_terrain() -> TileMap:
	return $terrain as TileMap

func get_manager() -> BattleManager:
	return manager

func get_mstar() -> MStar:
	return mstar

func get_terrain_collider() -> TileMap:
	return $terrain/collider as TileMap

func get_actors() -> Array:
	var actors = []
	
	for a in get_node("objects").get_children():
		if a.is_in_group("actors"):
			actors.append(a)
	
	return actors

func get_actors_from_group(g: int) -> Array:
	var actors = []
	
	for a in get_node("objects").get_children():
		if a.is_in_group("actors"):
			if a.group == g:
				actors.append(a)
	
	return actors

func map_to_world_fixed(position: Vector2) -> Vector2:
	var terrain = get_terrain()
	return terrain.map_to_world(position) + Vector2(0, terrain.get_cell_size().y * 0.5)

func _input(ev: InputEvent):
	if ev is InputEventKey && ev.scancode == KEY_W && ev.pressed:
		get_tree().set_input_as_handled()
		if get_terrain_collider().visible:
			get_terrain_collider().hide()
		else:
			get_terrain_collider().show()
