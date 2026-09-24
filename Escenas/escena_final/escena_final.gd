extends Node2D

@export var controlador_partida: ControladorPartida
@export var label_muertes: Label

@onready var _jugar: Button = $CanvasLayer/Centro/VBox/JugarDeNuevo
@onready var _volver: Button = $CanvasLayer/Centro/VBox/VolverAlMenu

func _ready() -> void:
	_jugar.pressed.connect(_al_jugar_de_nuevo)
	_volver.pressed.connect(_al_volver_al_menu)
	var muertes: int = ControladorGlobal.muertes
	controlador_partida.reiniciar_partida()
	label_muertes.text = "Muertes: %d" % muertes

func _al_jugar_de_nuevo() -> void:
	get_tree().change_scene_to_file("res://Escenas/escena_principal/escena_principal.tscn")

func _al_volver_al_menu() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu_principal/menu_principal.tscn")