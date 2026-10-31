extends "res://tests/test_gameplay.gd"
## A full M2 route using only input actions, with no teleports or cheats.


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	world = load("res://scenes/levels/gameplay_test.tscn").instantiate()
	root.add_child(world)
	var actor: CharacterBody2D = world.get_node("Player")
	var progress = world.get_node("LevelProgress")
	await seconds(0.9)
	await travel_to(actor, 205)
	check(progress.rune_count == 1, "route collects the ground rune")
	await travel_to(actor, 340)
	await travel_to(actor, 487, true)
	check(progress.rune_count == 2, "route clears the spikes and collects the first step rune")
	await travel_to(actor, 510)
	await travel_to(actor, 620, true)
	check(progress.rune_count == 3, "route climbs to the high step rune")
	await travel_to(actor, 720)
	check(progress.checkpoint_id == &"bridge", "route reaches the bridge checkpoint on foot")
	await travel_to(actor, 815)
	await travel_to(actor, 960, true)
	await travel_to(actor, 1070, true)
	check(progress.rune_count == 4, "route crosses the pit and second hazard to collect a rune")
	await travel_to(actor, 1190)
	await travel_to(actor, 1300, true)
	await travel_to(actor, 1340)
	await travel_to(actor, 1465, true)
	check(progress.rune_count == 5, "route reaches the upper platform and collects all five runes")
	await travel_to(actor, 1632)
	check(progress.checkpoint_id == &"lookout", "route finishes at the final checkpoint")
	check(actor.health.current_health == 3, "entire route can be traversed without damage")
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("TRAVERSAL RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func travel_to(actor: CharacterBody2D, destination_x: float, jump: bool = false) -> void:
	Input.action_press("move_right")
	if jump:
		Input.action_press("jump")
	# Release early in the air to leave room for the controller's braking.
	var release_x := destination_x - (20.0 if jump else 0.0)
	for index in tick_rate * 3:
		await frames(1)
		if actor.position.x >= release_x or actor.health.is_dead():
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	for index in ceili(tick_rate * 0.6):
		await frames(1)
		if actor.is_on_floor() and absf(actor.velocity.x) < 1:
			break
	check(absf(actor.position.x - destination_x) < 40 and actor.is_on_floor(),
		"input route reaches x=%d (actual %s)" % [int(destination_x), actor.position])
