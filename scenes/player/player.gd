extends CharacterBody2D

signal jumped(is_double: bool)
signal landed

const Tuning = preload("res://scripts/resources/player_tuning.gd")
@export var tuning: Resource = Tuning.new()

var facing: int = 1
var air_jump_available: bool = true
var _coyote_left: float = 0.0
var _buffer_left: float = 0.0


func _ready() -> void:
	jumped.connect($Visual.on_jumped)


func _physics_process(delta: float) -> void:
	# A buffered jump sets upward velocity after contact, while Godot's floor
	# flag still describes that contact. Do not refresh grace on the next tick.
	var grounded := is_on_floor() and velocity.y >= 0.0
	_coyote_left = maxf(0.0, _coyote_left - delta)
	_buffer_left = maxf(0.0, _buffer_left - delta)
	if grounded:
		_coyote_left = tuning.coyote_seconds
		air_jump_available = true
	else:
		velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)

	var axis := Input.get_axis("move_left", "move_right")
	var acceleration: float = tuning.ground_acceleration if grounded else tuning.air_acceleration
	if is_zero_approx(axis):
		acceleration = tuning.ground_deceleration if grounded else tuning.air_deceleration
	else:
		facing = 1 if axis > 0.0 else -1
	velocity.x = move_toward(velocity.x, axis * tuning.run_speed, acceleration * delta)

	var fresh_jump := Input.is_action_just_pressed("jump")
	if fresh_jump:
		_buffer_left = tuning.jump_buffer_seconds
	_try_jump(grounded, fresh_jump)
	_cut_released_jump()
	move_and_slide()

	if is_on_floor() and not grounded:
		air_jump_available = true
		_coyote_left = tuning.coyote_seconds
		landed.emit()
		# Consume buffered input on the contact frame, including short taps.
		_try_jump(true)
		_cut_released_jump()


func _try_jump(grounded: bool, fresh_press: bool = false) -> void:
	if _buffer_left <= 0.0 and not fresh_press:
		return
	var ground_jump := grounded or _coyote_left > 0.0
	if not ground_jump and not air_jump_available:
		return
	velocity.y = -tuning.jump_speed if ground_jump else -tuning.double_jump_speed
	if not ground_jump:
		air_jump_available = false
	_coyote_left = 0.0
	_buffer_left = 0.0
	jumped.emit(not ground_jump)


func _cut_released_jump() -> void:
	if not Input.is_action_pressed("jump"):
		velocity.y = maxf(velocity.y, -tuning.released_jump_speed)


func reset_to(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_coyote_left = 0.0
	_buffer_left = 0.0
	air_jump_available = true
	reset_physics_interpolation()
	$Camera2D.reset_smoothing()
