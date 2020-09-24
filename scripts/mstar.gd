class_name MStar

var width := 0
var height := 0
var astar: AStar2D

func _init(_width: int, _height: int):
	#set properties
	width = _width
	height = _height

	#create the AStar
	astar = AStar2D.new()

	#add the points
	for x in range(width):
		for y in range(height):
			astar.add_point(flatten(x, y), Vector2(x, y))

	#connect the points
	for x in range(width):
		for y in range(height):
			freec(x, y)

# HELPERS

func block_based_on_tilemap(tilemap: TileMap):
	for x in range(width):
		for y in range(height):
			if tilemap.get_cell(x, y) >= 0:
				forbid(x, y)

func get_size() -> Vector2:
	return Vector2(width, height)

func forbidv(_pos: Vector2):
	forbid(_pos.x, _pos.y)

func forbid(_x: float, _y: float):
	var current = flatten(_x, _y)
	disconnect_with_neighbour_at(current, Vector2( 1,  0))
	disconnect_with_neighbour_at(current, Vector2(-1,  0))
	disconnect_with_neighbour_at(current, Vector2( 0,  1))
	disconnect_with_neighbour_at(current, Vector2( 0, -1))

func freec(_x: float, _y: float):
	var current = flatten(_x, _y)
	connect_with_neighbour_at(current, Vector2( 1,  0))
	connect_with_neighbour_at(current, Vector2(-1,  0))
	connect_with_neighbour_at(current, Vector2( 0,  1))
	connect_with_neighbour_at(current, Vector2( 0, -1))

func freecv(_pos: Vector2):
	freec(_pos.x, _pos.y)

func flatten(_x: float, _y: float) -> int:
	return _x as int * width + _y as int

func point_within(_x: int, _y: int) -> bool:
	return (_x >= 0 && _y >= 0 && _x < width  && _y < height)

func disable_point(pos: Vector2):
	var id = flatten(pos.x, pos.y)
	astar.set_point_disabled(id)

func enable_point(pos: Vector2):
	var id = flatten(pos.x, pos.y)
	astar.set_point_disabled(id, false)

func connect_with_neighbour_at(id: int, offset: Vector2):
	var p = astar.get_point_position(id) + offset

	if point_within(p.x, p.y) && !astar.are_points_connected( id, flatten(p.x, p.y) ):
		astar.connect_points(id, flatten(p.x, p.y))

func disconnect_with_neighbour_at(id: int, offset: Vector2):
	var p = astar.get_point_position(id) + offset

	if point_within(p.x, p.y) && astar.are_points_connected( id, flatten(p.x, p.y) ):
		astar.disconnect_points(id, flatten(p.x, p.y))

func show_path_info(path: PoolVector2Array):
	print(path.size())
	
	for i in path:
		print(i)

func find_path(x1: float, y1: float, x2: float, y2: float) -> PoolVector2Array:
	return astar.get_point_path(flatten(floor(x1), floor(y1)), flatten(floor(x2), floor(y2)))

func find_path_v(_src: Vector2, _dest: Vector2) -> PoolVector2Array:
	return astar.get_point_path(flatten(floor(_src.x), floor(_src.y)), flatten(floor(_dest.x), floor(_dest.y)))
