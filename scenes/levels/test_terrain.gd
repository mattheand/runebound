extends TileMapLayer
## Two original 16px placeholder tiles with matching solid collision.


func _ready() -> void:
	tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(16, 16)
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	var image := Image.create(32, 16, false, Image.FORMAT_RGBA8)
	for y in 16:
		for x in 32:
			var local_x := x % 16
			var color := Color("3d5055")
			if y % 8 == 0 or (local_x + (y / 8 as int) * 8) % 16 == 0:
				color = Color("263b44")
			elif (local_x * 7 + y * 13) % 17 == 0:
				color = Color("607074")
			if x < 16:
				if y < 2:
					color = Color("a4b56a")
				elif y < 5 or (y < 8 and local_x % 5 == 0):
					color = Color("648850")
			image.set_pixel(x, y, color)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(16, 16)
	tile_set.add_source(atlas, 0)
	for x in 2:
		var coords := Vector2i(x, 0)
		atlas.create_tile(coords)
		var data := atlas.get_tile_data(coords, 0)
		data.set_collision_polygons_count(0, 1)
		data.set_collision_polygon_points(0, 0,
			PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]))


func fill_platform(rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			set_cell(Vector2i(x, y), 0, Vector2i(0 if y == rect.position.y else 1, 0))
