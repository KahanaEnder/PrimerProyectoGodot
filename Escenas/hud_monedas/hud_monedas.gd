class_name HudMonedas
extends Control

@export var label: Label

func iniciar(total: int) -> void:
	if total > 0:
		label.text = "Monedas: 0/%d" % total
	else:
		label.text = ""

func actualizar(recogidas: int, total: int) -> void:
	label.text = "Monedas: %d/%d" % [recogidas, total]