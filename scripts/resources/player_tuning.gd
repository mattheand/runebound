class_name PlayerTuning
extends Resource
## Distances are logical pixels; speeds are pixels per second.

@export_range(1, 1000, 1) var run_speed: float = 220.0
@export_range(1, 10000, 1) var ground_acceleration: float = 2200.0
@export_range(1, 10000, 1) var ground_deceleration: float = 2600.0
@export_range(1, 10000, 1) var air_acceleration: float = 1600.0
@export_range(1, 10000, 1) var air_deceleration: float = 750.0
@export_range(1, 5000, 1) var gravity: float = 1450.0
@export_range(1, 2000, 1) var terminal_velocity: float = 900.0
@export_range(1, 2000, 1) var jump_speed: float = 510.0
@export_range(1, 2000, 1) var double_jump_speed: float = 460.0
@export_range(1, 1000, 1) var released_jump_speed: float = 140.0
@export_range(0, 0.5, 0.005) var coyote_seconds: float = 0.1
@export_range(0, 0.5, 0.005) var jump_buffer_seconds: float = 0.12
