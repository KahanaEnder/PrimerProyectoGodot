class_name ContenedorMonedas
extends Node

signal completado
signal progreso(recogidas: int, total: int)

@export var reproductor: AudioStreamPlayer2D

var _total_monedas: int
var _monedas_recogidas: int

func _ready() -> void:
	add_to_group("contenedor_monedas")
	for hijo in get_children():
		if hijo.is_in_group("monedas"):
			_total_monedas += 1
			hijo.recogida.connect(_moneda_recogida.bind(hijo))

func _moneda_recogida(moneda: Node2D) -> void:
	_monedas_recogidas += 1
	reproductor.global_position = moneda.global_position
	reproductor.play()
	progreso.emit(_monedas_recogidas, _total_monedas)
	if _monedas_recogidas == _total_monedas:
		completado.emit()

func total_monedas() -> int:
	return _total_monedas		
