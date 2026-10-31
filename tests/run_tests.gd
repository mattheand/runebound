extends SceneTree

var failures: int = 0
var checks: int = 0
var world: Node2D
var player: CharacterBody2D
var jumps: Array[bool] = []
var landings: int = 0
var tick_rate: int = 60


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		printerr("FAIL: ", message)


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scenes/main/main.tscn"), "M0 main scene exists")
	if failures == 0:
		var main: Node = load("res://scenes/main/main.tscn").instantiate()
		root.add_child(main)
		await process_frame
		check(main.is_inside_tree(), "M0 main scene starts")
		main.queue_free()
		await process_frame
	await test_run_and_brake()
	await test_jump_height()
	await test_air_jump_budget()
	await test_zero_buffer()
	await test_coyote(false)
	await test_coyote(true)
	await test_buffer(false)
	await test_buffer(true)
	await test_buffer_expiry()
	await test_collisions()
	await cleanup()
	await test_playground()
	print("RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame


func seconds(duration: float) -> void:
	await frames(maxi(1, roundi(duration * tick_rate)))


func cleanup() -> void:
	for action in ["move_left", "move_right", "jump", "restart", "pause"]:
		Input.action_release(action)
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	jumps.clear()
	landings = 0


func fixture(floor_end: float = 3000.0) -> void:
	await cleanup()
	world = Node2D.new()
	root.add_child(world)
	add_block(Rect2(-1000, 300, floor_end + 1000, 64))
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector2(100, 280)
	player.get_node("Camera2D").enabled = false
	world.add_child(player)
	if player.has_signal("jumped"):
		player.connect("jumped", func(is_double: bool) -> void: jumps.append(is_double))
	if player.has_signal("landed"):
		player.connect("landed", func() -> void: landings += 1)
	await seconds(0.25)


func add_block(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	world.add_child(body)


# Catches missing delta scaling, slippery braking and absent air steering.
func test_run_and_brake() -> void:
	await fixture()
	check(player.is_on_floor(), "gravity lands the player on the floor")
	Input.action_press("move_right")
	await seconds(0.5)
	check(player.position.x > 175 and player.position.x < 220, "running covers a responsive, bounded distance")
	check(player.velocity.x > 180 and player.velocity.x < 250, "running has a speed cap")
	Input.action_release("move_right")
	var release_x := player.position.x
	await seconds(0.15)
	check(absf(player.velocity.x) < 1 and player.position.x - release_x < 20, "release brakes quickly")
	Input.action_press("jump")
	Input.action_press("move_left")
	await seconds(0.15)
	check(player.velocity.x < -100 and player.position.y < 270, "air control reverses horizontal movement")


func jump_apex(hold_time: float) -> float:
	await fixture()
	Input.action_press("jump")
	var minimum_y := player.position.y
	for index in roundi(tick_rate * 0.9):
		if index >= roundi(hold_time * tick_rate):
			Input.action_release("jump")
		await frames(1)
		minimum_y = minf(minimum_y, player.position.y)
	return 300.0 - minimum_y


# Catches fixed-height jumps and auto-jumping while the button is held.
func test_jump_height() -> void:
	var held := await jump_apex(0.8)
	var tapped := await jump_apex(0.04)
	print("METRIC: held apex=", held, ", tap apex=", tapped)
	check(held > 75 and held < 115, "held jump reaches a useful single-jump height")
	check(tapped > 10 and tapped < held * 0.75, "tapping makes a substantially lower jump")
	await fixture()
	Input.action_press("jump")
	await seconds(1.5)
	check(player.is_on_floor() and jumps.size() == 1, "holding jump never auto-repeats")


# Catches unlimited air jumps and failure to restore the budget on landing.
func test_air_jump_budget() -> void:
	await fixture()
	Input.action_press("jump")
	await seconds(0.12)
	Input.action_release("jump")
	await frames(1)
	Input.action_press("jump")
	await frames(1)
	check(player.velocity.y < -300 and jumps == [false, true], "second press creates a distinct air jump")
	Input.action_release("jump")
	await frames(1)
	var previous_velocity := player.velocity.y
	Input.action_press("jump")
	await frames(1)
	check(jumps.size() == 2 and player.velocity.y > previous_velocity, "third airborne press cannot jump")
	Input.action_release("jump")
	await seconds(1.0)
	check(player.is_on_floor() and landings >= 2, "landing is detected after the double jump")
	Input.action_press("jump")
	await frames(1)
	check(player.velocity.y < -300 and jumps == [false, true, false], "landing restores the ground jump")


# Setting grace to zero must disable buffering, not fresh jump input.
func test_zero_buffer() -> void:
	await fixture()
	player.tuning = player.tuning.duplicate()
	player.tuning.jump_buffer_seconds = 0.0
	Input.action_press("jump")
	await frames(1)
	check(jumps == [false] and player.velocity.y < -300, "zero buffer still permits a fresh ground jump")
	Input.action_release("jump")
	await frames(1)
	Input.action_press("jump")
	await frames(1)
	check(jumps == [false, true] and player.velocity.y < -300, "zero buffer still permits a fresh air jump")


# Ground grace must preserve the air jump; expired grace must not grant two.
func test_coyote(expired: bool) -> void:
	await fixture(160)
	Input.action_press("move_right")
	for index in tick_rate:
		await frames(1)
		if not player.is_on_floor():
			break
	check(not player.is_on_floor(), "player walks off test ledge")
	Input.action_release("move_right")
	await seconds(0.16 if expired else 0.025)
	Input.action_press("jump")
	await frames(1)
	check(jumps == [expired] and player.velocity.y < -300,
		"expired coyote uses air jump" if expired else "coyote jump preserves air jump")
	Input.action_release("jump")
	await frames(1)
	Input.action_press("jump")
	await frames(1)
	check(jumps.size() == (1 if expired else 2), "ledge fall respects remaining air-jump budget")


func exhaust_air_jumps() -> void:
	Input.action_press("jump")
	await seconds(0.12)
	Input.action_release("jump")
	await frames(1)
	Input.action_press("jump")
	await seconds(0.1)
	Input.action_release("jump")


# An exhausted player can buffer a press just before landing, even a tap.
func test_buffer(tapped: bool) -> void:
	await fixture()
	await exhaust_air_jumps()
	for index in tick_rate * 2:
		await frames(1)
		if player.velocity.y > 0 and player.position.y > 265:
			break
	Input.action_press("jump")
	await frames(1)
	if tapped:
		Input.action_release("jump")
	for index in roundi(tick_rate * 0.15) + 2:
		await frames(1)
		if jumps.size() >= 3:
			break
	check(jumps == [false, true, false] and player.velocity.y < 0,
		"released buffered tap jumps on landing" if tapped else "buffered jump fires on landing")
	if tapped:
		check(player.velocity.y > -300, "released buffered tap retains short jump height")


func test_buffer_expiry() -> void:
	await fixture()
	await exhaust_air_jumps()
	await frames(1)
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await seconds(1.2)
	check(player.is_on_floor() and jumps.size() == 2, "expired buffer cannot trigger a stale jump on landing")


# Catches incorrect collision masks and body dimensions at walls/ceilings.
func test_collisions() -> void:
	await fixture()
	add_block(Rect2(200, 150, 32, 150))
	Input.action_press("move_right")
	await seconds(0.8)
	check(player.position.x <= 191.1 and player.is_on_wall(), "wall blocks horizontal movement without clipping")
	Input.action_release("move_right")
	await fixture()
	add_block(Rect2(40, 230, 140, 16))
	Input.action_press("jump")
	var hit_ceiling := false
	var minimum_y := player.position.y
	for index in roundi(tick_rate * 0.4):
		await frames(1)
		minimum_y = minf(minimum_y, player.position.y)
		hit_ceiling = hit_ceiling or player.is_on_ceiling()
	check(hit_ceiling and minimum_y >= 277.9, "ceiling stops upward movement without clipping")


# Exercise the shipped scene, not just the controlled collision fixture.
func test_playground() -> void:
	var menu: Control = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.find_child("MovementButton", true, false).pressed.emit()
	await frames(2)
	var course := current_scene
	check(course != null and course.name == "MovementTest", "Start opens the playable course")
	if course == null:
		return
	var hero: CharacterBody2D = course.get_node("Player")
	var camera: Camera2D = hero.get_node("Camera2D")
	await seconds(0.5)
	check(hero.is_on_floor(), "course spawn lands on real terrain")
	check(camera.enabled, "course camera is active")
	Input.action_press("move_right")
	Input.action_press("jump")
	await seconds(0.25)
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_press("restart")
	await frames(1)
	Input.action_release("restart")
	check(hero.position.distance_to(Vector2(96, 416)) < 8 and hero.velocity.length() < 50,
		"restart returns to spawn and clears momentum")
	hero.position = Vector2(900, 900)
	await frames(2)
	check(hero.position.distance_to(Vector2(96, 416)) < 12, "falling out of course automatically resets")
	hero.position = Vector2(1400, 350)
	await seconds(1.0)
	check(camera.get_screen_center_position().x > 1000, "camera follows horizontal traversal")
	hero.position = Vector2(2500, 430)
	await seconds(1.0)
	var center := camera.get_screen_center_position()
	check(center.x <= 2241 and center.y >= 179 and center.y <= 541, "camera respects course boundaries")
	Input.action_press("pause")
	await frames(2)
	Input.action_release("pause")
	check(current_scene != course and current_scene.name == "MainMenu", "Escape returns to the menu")
	current_scene.queue_free()
	await process_frame
