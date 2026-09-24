extends Node2D

var _completado := false
var _reinicio := false

func _on_completado() -> void:
	_completado = true

func _on_reinicio() -> void:
	_reinicio = true

func _ready() -> void:
	var fallos: Array[String] = []
	ControladorGlobal.nivel = 0
	ControladorGlobal.muertes = 0

	# --- Flujo principal: monedas avanzan de nivel ---
	var escena: Node = load("res://Escenas/escena_principal/escena_principal.tscn").instantiate()
	add_child(escena)
	await get_tree().process_frame

	var contenedor = get_tree().get_first_node_in_group("contenedor_monedas")
	if contenedor == null:
		fallos.append("contenedor_monedas no encontrado")
		_finalizar(fallos)
		return
	var monedas := get_tree().get_nodes_in_group("monedas").filter(func(m): return m.get_parent() == contenedor)
	if monedas.size() != 3:
		fallos.append("se esperaban 3 monedas en nivel 1, hay %s" % monedas.size())

	contenedor.connect("completado", _on_completado)
	for moneda in monedas:
		moneda.emit_signal("recogida")
	if not _completado:
		fallos.append("completado no se emitió al recoger todas las monedas")
	await get_tree().process_frame
	await get_tree().process_frame
	if ControladorGlobal.nivel != 1:
		fallos.append("tras completar nivel 1, ControladorGlobal.nivel=%s (esperaba 1)" % ControladorGlobal.nivel)

	# --- Muerte: reinicia el nivel manteniendo el nivel ---
	var personaje = get_tree().get_first_node_in_group("personajes")
	if personaje == null:
		fallos.append("personaje no encontrado")
	else:
		personaje.connect("personaje_muerto", _on_reinicio)
		personaje.emit_signal("personaje_muerto")
		if not _reinicio:
			fallos.append("personaje_muerto no conectado al reinicio")
		await get_tree().process_frame
		await get_tree().process_frame
		if ControladorGlobal.nivel != 1:
			fallos.append("al morir cambió de nivel: %s" % ControladorGlobal.nivel)

	# --- Flujo ganar: escena_final reinicia la partida ---
	escena.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	ControladorGlobal.nivel = 2
	ControladorGlobal.muertes = 7
	var final_scene: Node = load("res://Escenas/escena_final/escena_final.tscn").instantiate()
	add_child(final_scene)
	await get_tree().process_frame
	if ControladorGlobal.nivel != 0:
		fallos.append("escena_final no reinició nivel (queda %s)" % ControladorGlobal.nivel)
	if ControladorGlobal.muertes != 0:
		fallos.append("escena_final no reinició muertes (quedan %s)" % ControladorGlobal.muertes)

	await get_tree().process_frame
	await get_tree().process_frame
	final_scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_finalizar(fallos)

func _finalizar(fallos: Array[String]) -> void:
	if fallos.is_empty():
		print("FASE_A_OK")
		get_tree().quit(0)
	else:
		for f in fallos:
			printerr("FAIL: " + f)
		get_tree().quit(1)
