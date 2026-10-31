extends CharacterBody2D
## A stationary damage fixture, not an enemy controller or AI.

var _home: Vector2
var _flash_left: float = 0.0


func _ready() -> void:
	_home = position
	$HealthComponent.damaged.connect(_on_damaged)
	$HealthComponent.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if $HealthComponent.is_dead():
		return
	velocity.x = move_toward(velocity.x, 0.0, 750.0 * delta)
	velocity.y = minf(velocity.y + 1450.0 * delta, 900.0)
	move_and_slide()
	if position.y > _home.y + 500:
		reset_target()


func _process(delta: float) -> void:
	_flash_left = maxf(0, _flash_left - delta)
	queue_redraw()


func _on_damaged(_amount: int, impulse: Vector2) -> void:
	velocity = impulse
	_flash_left = 0.14


func _on_died() -> void:
	visible = false
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)


func reset_target() -> void:
	position = _home
	velocity = Vector2.ZERO
	_flash_left = 0.0
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	$HealthComponent.reset_health()
	reset_physics_interpolation()


func _draw() -> void:
	var color := Color("ffe4ba") if _flash_left > 0.0 else Color("b88655")
	draw_rect(Rect2(-3, -38, 6, 38), Color("735143"))
	draw_rect(Rect2(-13, -30, 26, 19), color)
	draw_rect(Rect2(-7, -40, 14, 11), color)
	draw_circle(Vector2(0, -20), 6, Color("d44a4f"))
	draw_circle(Vector2(0, -20), 2, Color("e9d8a6"))
	for index in $HealthComponent.max_health:
		draw_rect(Rect2(-10 + index * 7, -48, 5, 3),
			Color("d44a4f") if index < $HealthComponent.current_health else Color("263b44"))
