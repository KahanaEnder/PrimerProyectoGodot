extends Node2D

@export var controlador_partida: ControladorPartida

func _ready() -> void:
	controlador_partida.reiniciar_partida()