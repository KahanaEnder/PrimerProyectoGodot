extends CharacterBody2D

signal personaje_muerto

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
@export var material_personaje_rojo: ShaderMaterial

var _velocidad: float = 100.0
var _velocidad_salto: float = -300.0
var _muerto: bool

func _ready() -> void:
	add_to_group("personajes")
	area_2d.body_entered.connect(funcion_colision_entrante_area2d_conectada)

func _physics_process(delta: float) -> void:
	
	if _muerto:
		return
	
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _velocidad_salto
	if Input.is_action_pressed("derecha"):
		velocity.x = _velocidad
		animacion.play("correr")
		animacion.flip_h = true
	elif Input.is_action_pressed("izquierda"):
		velocity.x = -_velocidad
		animacion.play("correr")
		animacion.flip_h = false
	else:
		velocity.x = 0
		animacion.play("idle")
	move_and_slide()
	
	if !is_on_floor():
		animacion.play("saltar")
		
func funcion_colision_entrante_area2d_conectada(_body: Node2D) -> void:
	animacion.material = material_personaje_rojo
	_muerto = true
	animacion.stop()
	await get_tree().create_timer(0.5).timeout
	personaje_muerto.emit()
	ControladorGlobal.sumar_muerte()
