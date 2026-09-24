extends Node2D

signal recogida

@export var area2d: Area2D

func _ready() -> void:
	add_to_group("monedas")
	area2d.body_entered.connect(_recogida)
	_iniciar_animacion()

func _recogida(_body):
	recogida.emit()
	queue_free()

func _iniciar_animacion():
	var tween: Tween = create_tween().bind_node(self)
	tween.set_loops(0)
	tween.tween_property(self, "position:y", position.y - 5, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y + 5, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
