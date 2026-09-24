class_name Enemigo
extends CharacterBody2D

@export var rayo_pared: RayCast2D
@export var rayo_borde: RayCast2D
@export var sprite: Sprite2D

const _VELOCIDAD: float = 45.0
const _TIEMPO_ESPERA: float = 0.25

@export var alcance: float = 600.0

var _direccion := -1
var _x_inicial: float
var _tiempo_espera: float = 0.0
var _esperando := false

func _ready() -> void:
	_x_inicial = position.x

func _physics_process(delta: float) -> void:
	if _esperando:
		_tiempo_espera -= delta
		if _tiempo_espera <= 0.0:
			_esperando = false
		velocity.x = 0.0
		move_and_slide()
		return

	rayo_pared.target_position = Vector2(_direccion * 10.0, 0.0)
	rayo_borde.position.x = 8.0 * _direccion
	rayo_borde.target_position = Vector2(0.0, 24.0)

	if rayo_pared.is_colliding() or not rayo_borde.is_colliding() or absf(position.x - _x_inicial) > alcance:
		_direccion *= -1
		_esperando = true
		_tiempo_espera = _TIEMPO_ESPERA

	velocity.x = _VELOCIDAD * _direccion
	sprite.flip_h = _direccion < 0.0
	move_and_slide()
