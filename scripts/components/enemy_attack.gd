extends Node2D
## Reusable attack clock shared by ground, flight and boss controllers.

signal phase_changed(phase: StringName)
signal active_started
signal finished

var phase: StringName = &"idle"
var elapsed: float = 0.0
var profile: Resource
var facing: int = 1


func is_running() -> bool:
	return phase != &"idle"


func start(attack_profile: Resource, direction: int) -> bool:
	if is_running() or get_parent().health.is_dead():
		return false
	profile = attack_profile
	facing = 1 if direction >= 0 else -1
	scale.x = facing
	$Hitbox.position = profile.offset
	var shape := RectangleShape2D.new()
	shape.size = profile.size
	$Hitbox/Shape.shape = shape
	$Hitbox.damage = profile.damage
	$Hitbox.knockback = profile.knockback
	elapsed = 0.0
	phase = &"windup"
	phase_changed.emit(phase)
	return true


func cancel() -> void:
	phase = &"idle"
	elapsed = 0.0
	$Hitbox.end_swing()


func begin_recovery() -> void:
	if not is_running() or phase == &"recovery":
		return
	elapsed = profile.windup + profile.active
	phase = &"recovery"
	$Hitbox.active = false
	phase_changed.emit(phase)


func _physics_process(delta: float) -> void:
	if not is_running():
		return
	if get_parent().health.is_dead():
		cancel()
		return
	elapsed += delta
	if elapsed >= profile.windup + profile.active + profile.recovery:
		cancel()
		finished.emit()
	elif elapsed >= profile.windup + profile.active:
		if phase != &"recovery":
			begin_recovery()
	elif elapsed >= profile.windup:
		if phase == &"windup":
			phase = &"active"
			$Hitbox.begin_swing(facing)
			phase_changed.emit(phase)
			active_started.emit()
			$Sound.play()
		$Hitbox.sample_hits()
