extends StaticBody2D

signal shattered

var broken: bool = false
var _flash_left: float = 0.0


func _ready() -> void:
	$HealthComponent.damaged.connect(_on_damaged)
	$HealthComponent.died.connect(_on_shattered)


func _on_damaged(_amount: int, _impulse: Vector2) -> void:
	_flash_left = 0.15


func _on_shattered() -> void:
	broken = true
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox.set_deferred("monitorable", false)
	shattered.emit()


func _process(delta: float) -> void:
	_flash_left = maxf(0, _flash_left - delta)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-16, -64, 32, 64), Color("adc1b3") if _flash_left > 0 else Color("526967"))
	draw_polyline(PackedVector2Array([Vector2(-3, -64), Vector2(8, -49), Vector2(-5, -32), Vector2(5, -15), Vector2(-7, 0)]), Color("72d7d8"), 2)
	draw_rect(Rect2(-18, -64, 36, 5), Color("748855"))
