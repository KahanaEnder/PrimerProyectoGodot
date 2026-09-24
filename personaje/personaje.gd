extends CharacterBody2D

signal personaje_muerto

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
@export var material_personaje_rojo: ShaderMaterial

const _VELOCIDAD_MAXIMA: float = 120.0
const _ACELERACION: float = 1400.0
const _FRICCION: float = 1600.0
const _VELOCIDAD_SALTO: float = -330.0
const _GRAVEDAD_CAIDA: float = 1.7
const _TIEMPO_COYOTE: float = 0.1
const _TIEMPO_BUFFER: float = 0.12
const _CORTE_SALTO: float = 0.45

var _coyote: float = 0.0
var _buffer: float = 0.0
var _en_suelo_anterior: bool = true
var _muerto: bool

func _ready() -> void:
	add_to_group("personajes")
	area_2d.body_entered.connect(funcion_colision_entrante_area2d_conectada)

func _physics_process(delta: float) -> void:
	if _muerto:
		return

	_coyote = _TIEMPO_COYOTE if is_on_floor() else _coyote - delta
	_buffer = _TIEMPO_BUFFER if Input.is_action_just_pressed("saltar") else _buffer - delta

	var direccion := Input.get_axis("izquierda", "derecha")
	if direccion != 0.0:
		velocity.x = move_toward(velocity.x, direccion * _VELOCIDAD_MAXIMA, _ACELERACION * delta)
		animacion.flip_h = direccion > 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, _FRICCION * delta)

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = _VELOCIDAD_SALTO
		_buffer = 0.0
		_coyote = 0.0
		_reproducir_squash_y_estiramiento(true)

	if Input.is_action_just_released("saltar") and velocity.y < 0.0:
		velocity.y *= _CORTE_SALTO

	var gravedad := get_gravity().y * (_GRAVEDAD_CAIDA if velocity.y > 0.0 else 1.0)
	velocity.y += gravedad * delta
	move_and_slide()

	_actualizar_animacion()
	if not _en_suelo_anterior and is_on_floor():
		_reproducir_squash_y_estiramiento(false)
	_en_suelo_anterior = is_on_floor()

func _actualizar_animacion() -> void:
	if not is_on_floor():
		if animacion.animation != &"saltar":
			animacion.play("saltar")
	elif absf(velocity.x) > 10.0:
		if animacion.animation != &"correr":
			animacion.play("correr")
	else:
		if animacion.animation != &"idle":
			animacion.play("idle")

func _reproducir_squash_y_estiramiento(salto: bool) -> void:
	var tween := create_tween().bind_node(animacion)
	var escala: Vector2 = Vector2(1.15, 0.85) if salto else Vector2(1.25, 0.8)
	tween.tween_property(animacion, "scale", escala, 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(animacion, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func funcion_colision_entrante_area2d_conectada(_body: Node2D) -> void:
	animacion.material = material_personaje_rojo
	_muerto = true
	animacion.stop()
	await get_tree().create_timer(0.5).timeout
	personaje_muerto.emit()
	ControladorGlobal.sumar_muerte()