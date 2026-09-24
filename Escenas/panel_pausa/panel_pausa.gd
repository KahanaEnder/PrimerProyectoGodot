class_name PanelPausa
extends CanvasLayer

signal reiniciar_solicitado
signal salir_solicitado

var _pausado: bool = false

@onready var _vista: Control = $Vista
@onready var _continuar: Button = $Vista/Centro/VBox/Continuar
@onready var _reiniciar: Button = $Vista/Centro/VBox/ReiniciarNivel
@onready var _salir: Button = $Vista/Centro/VBox/VolverAlMenu

func _ready() -> void:
	_continuar.pressed.connect(_reanudar)
	_reiniciar.pressed.connect(_al_reiniciar)
	_salir.pressed.connect(_al_salir)
	_vista.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		if _pausado:
			_reanudar()
		else:
			_pausar()

func _pausar() -> void:
	_pausado = true
	_vista.show()
	get_tree().paused = true

func _reanudar() -> void:
	_pausado = false
	_vista.hide()
	get_tree().paused = false

func _al_reiniciar() -> void:
	_reanudar()
	reiniciar_solicitado.emit()

func _al_salir() -> void:
	_reanudar()
	salir_solicitado.emit()