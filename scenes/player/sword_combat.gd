extends Node2D
## A single physics clock drives both hitbox timing and slash presentation.

const Tuning = preload("res://scripts/resources/combat_tuning.gd")
@export var tuning: Resource = Tuning.new()

var phase: StringName = &"idle"
var elapsed: float = 0.0
var facing: int = 1
var _impact_left: float = 0.0


func _ready() -> void:
	$Hitbox.hit.connect(_on_hit)


func is_attacking() -> bool:
	return phase != &"idle"


func try_attack(direction: int) -> bool:
	if is_attacking() or get_parent().health.is_dead():
		return false
	facing = 1 if direction >= 0 else -1
	scale.x = facing
	elapsed = 0.0
	phase = &"windup"
	$Hitbox.damage = tuning.damage
	$Hitbox.knockback = tuning.knockback
	queue_redraw()
	return true


func cancel() -> void:
	phase = &"idle"
	elapsed = 0.0
	_impact_left = 0.0
	$Hitbox.end_swing()
	queue_redraw()


func _physics_process(delta: float) -> void:
	_impact_left = maxf(0.0, _impact_left - delta)
	if is_attacking():
		elapsed += delta
		if elapsed >= tuning.windup_seconds + tuning.active_seconds + tuning.recovery_seconds:
			cancel()
		elif elapsed >= tuning.windup_seconds + tuning.active_seconds:
			phase = &"recovery"
			$Hitbox.active = false
		elif elapsed >= tuning.windup_seconds:
			if phase == &"windup":
				phase = &"active"
				$Hitbox.begin_swing(facing)
				$SwingSound.play()
			$Hitbox.sample_hits()
	queue_redraw()


func _on_hit(_target: Node) -> void:
	_impact_left = 0.15
	$ImpactSound.play()


func _draw() -> void:
	if phase == &"windup":
		draw_line(Vector2(8, 0), Vector2(14, -22), Color("e1d8b9"), 3)
	elif phase == &"active":
		draw_arc(Vector2(5, 0), 34, -0.9, 0.9, 12, Color("e6f7da"), 3)
		draw_line(Vector2(9, 0), Vector2(38, -3), Color("d9e6e0"), 3)
	elif phase == &"recovery":
		draw_line(Vector2(8, 0), Vector2(25, 12), Color("9caeb4"), 2)
	if _impact_left > 0.0:
		for index in 5:
			var ray := Vector2.from_angle(index * TAU / 5.0)
			draw_line(Vector2(34, 0) + ray * 6, Vector2(34, 0) + ray * 12, Color("e9d8a6"), 2)
