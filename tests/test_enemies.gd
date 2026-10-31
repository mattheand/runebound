extends "res://tests/test_gameplay.gd"

var states_seen: Array[StringName] = []
var defeated_count: int = 0


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scenes/enemies/draugr.tscn"), "Draugr scene exists")
	if failures == 0:
		await test_draugr()
		await test_draugr_ledge()
		await test_detection_occlusion()
		check(ResourceLoader.exists("res://scenes/enemies/raven.tscn"), "Raven scene exists")
		if ResourceLoader.exists("res://scenes/enemies/raven.tscn"):
			await test_raven()
			await test_raven_damage()
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("ENEMY RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func spawn_enemy(path: String, at: Vector2) -> CharacterBody2D:
	var enemy: CharacterBody2D = load(path).instantiate()
	enemy.position = at
	world.add_child(enemy)
	return enemy


func test_draugr() -> void:
	await fixture()
	var actor := make_player()
	actor.position.x = -400
	var enemy := spawn_enemy("res://scenes/enemies/draugr.tscn", Vector2(400, 300))
	states_seen.clear()
	enemy.state_changed.connect(func(_old: StringName, next: StringName) -> void: states_seen.append(next))
	var min_x := 400.0
	var max_x := 400.0
	for index in tick_rate * 4:
		await frames(1)
		min_x = minf(min_x, enemy.position.x)
		max_x = maxf(max_x, enemy.position.x)
	check(min_x >= 318 and max_x <= 482 and max_x - min_x > 20, "Draugr patrol stays within its home bounds")
	check(states_seen.has(&"patrol"), "Draugr enters patrol from idle")
	actor.position = enemy.position + Vector2(-120, 0)
	await seconds(0.3)
	check(enemy.state == &"chase" and enemy.velocity.x < 0, "Draugr detects and chases a nearby living player")
	actor.position = enemy.position + Vector2(-30, 0)
	actor.set_physics_process(false)
	await frames(2)
	check(enemy.state == &"attack" and actor.health.current_health == 3, "Draugr winds up before dealing melee damage")
	await seconds(0.45)
	check(actor.health.current_health == 2, "Draugr active melee damages the player")
	await seconds(0.3)
	check(actor.health.current_health == 2, "Draugr recovery does not repeatedly damage the player")
	enemy.health.take_damage(1, Vector2(150, -90))
	check(enemy.state == &"hurt" and not enemy.get_node("Attack").is_running(), "Draugr hurt interrupts its attack")
	await seconds(0.1)
	check(enemy.velocity.x > 0, "Draugr receives hit knockback")
	await seconds(0.3)
	check(enemy.state != &"hurt", "Draugr exits its brief hurt state")
	actor.health.kill()
	await seconds(0.2)
	check(enemy.state != &"chase" and enemy.state != &"attack", "Draugr stops targeting a dead player")
	defeated_count = 0
	enemy.defeated.connect(func(_actor: Node2D) -> void: defeated_count += 1)
	enemy.health.kill()
	var death_position := enemy.position
	await seconds(0.8)
	check(enemy.state == &"dead" and enemy.position == death_position and not enemy.visible, "Draugr death ends movement and fades the body")
	check(defeated_count == 1 and not enemy.get_node("Attack").is_running(), "Draugr defeat is emitted once with no lingering attack")
	enemy.reset_enemy()
	check(enemy.health.current_health == 3 and enemy.visible and enemy.position == Vector2(400, 300), "Draugr resets to full health at its home")


func test_draugr_ledge() -> void:
	await cleanup()
	world = Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(400, 316)
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(100, 32)
	collider.shape = shape
	floor_body.add_child(collider)
	world.add_child(floor_body)
	var enemy := spawn_enemy("res://scenes/enemies/draugr.tscn", Vector2(400, 300))
	await seconds(5)
	check(enemy.position.x > 350 and enemy.position.x < 450 and enemy.is_on_floor(), "Draugr turns around at an unsupported ledge")


func test_detection_occlusion() -> void:
	await fixture()
	var actor := make_player()
	actor.position = Vector2(280, 300)
	var wall := StaticBody2D.new()
	wall.position = Vector2(340, 230)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 140)
	collision.shape = shape
	wall.add_child(collision)
	world.add_child(wall)
	var enemy := spawn_enemy("res://scenes/enemies/draugr.tscn", Vector2(400, 300))
	await seconds(0.6)
	check(enemy.state != &"chase" and enemy.state != &"attack", "solid terrain occludes enemy detection")
	wall.queue_free()
	await seconds(0.3)
	check(enemy.state == &"chase", "removing the obstruction restores detection")


func wait_state(enemy: Node, desired: StringName, timeout_seconds: float = 2.0) -> bool:
	for index in ceili(tick_rate * timeout_seconds):
		await frames(1)
		if enemy.state == desired:
			return true
	return false


func test_raven() -> void:
	await fixture()
	var actor := make_player()
	actor.position.x = -400
	var raven := spawn_enemy("res://scenes/enemies/raven.tscn", Vector2(400, 170))
	await seconds(1.0)
	check(absf(raven.position.y - 170) < 1 and absf(raven.position.x - 400) > 10, "Raven flies a level patrol route")
	actor.position = Vector2(raven.position.x - 60, 300)
	check(await wait_state(raven, &"telegraph"), "Raven warns before diving at a detected player")
	var locked_direction: Vector2 = raven.dive_direction
	actor.position.x += 150
	check(await wait_state(raven, &"dive"), "Raven warning transitions to an active dive")
	check(raven.dive_direction.is_equal_approx(locked_direction), "Raven does not re-aim or home during its warned dive")
	check(await wait_state(raven, &"recovery"), "Raven ends its dive with a recovery window")
	check(not raven.attack.get_node("Hitbox").active, "Raven recovery disables damage")
	actor.position.x = -400
	check(await wait_state(raven, &"patrol", 3.0), "Raven returns to its original patrol route")
	check(absf(raven.position.y - 170) < 3, "Raven recovers its original flight altitude")


func test_raven_damage() -> void:
	await fixture()
	var actor := make_player()
	actor.position = Vector2(340, 300)
	actor.set_physics_process(false)
	var raven := spawn_enemy("res://scenes/enemies/raven.tscn", Vector2(400, 170))
	check(await wait_state(raven, &"telegraph"), "Raven acquires a stationary target")
	check(actor.health.current_health == 3, "Raven wind-up cannot damage")
	check(await wait_state(raven, &"recovery"), "Raven finishes a contact dive")
	check(actor.health.current_health == 2, "one Raven dive deals exactly one hit")
	raven.health.take_damage(1, Vector2(100, -70))
	check(raven.state == &"hurt" and not raven.attack.is_running(), "Raven hurt cancels attack and applies a recovery state")
	actor.position.x = -400
	check(await wait_state(raven, &"patrol", 3.0), "hurt Raven can return to patrol")
	raven.health.kill()
	var death_position := raven.position
	await seconds(0.8)
	check(raven.state == &"dead" and raven.position == death_position and not raven.visible, "dead Raven stops flying and attacking")
	raven.reset_enemy()
	check(raven.health.current_health == 2 and raven.position == Vector2(400, 170) and raven.state == &"patrol", "Raven reset restores its route and health")
