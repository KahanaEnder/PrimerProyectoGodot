extends Node2D

func _ready() -> void:
	var fallos: Array[String] = []
	ControladorGlobal.nivel = 0
	ControladorGlobal.muertes = 0

	# --- HUD de monedas ---
	var escena: Node = load("res://Escenas/escena_principal/escena_principal.tscn").instantiate()
	add_child(escena)
	await get_tree().process_frame
	await get_tree().process_frame

	var hud: Node = escena.get("hud_monedas")
	if hud == null or not hud.visible:
		fallos.append("hud_monedas no visible tras crear nivel")
	elif hud.label.text != "Monedas: 0/3":
		fallos.append("hud inicial incorrecto: %s" % hud.label.text)

	var contenedor = get_tree().get_first_node_in_group("contenedor_monedas")
	if contenedor == null:
		fallos.append("contenedor_monedas no encontrado")
	else:
		var moneda = get_tree().get_nodes_in_group("monedas").filter(func(m): return m.get_parent() == contenedor)[0]
		moneda.recogida.emit()
		await get_tree().process_frame
		if hud == null or hud.label.text != "Monedas: 1/3":
			fallos.append("hud no se actualizó tras recoger: %s" % (hud.label.text if hud else "sin hud"))
		if not contenedor.has_signal("progreso"):
			fallos.append("falta señal progreso en contenedor")

	# --- Menú de pausa ---
	var panel = escena.get("panel_pausa")
	if panel == null:
		fallos.append("panel_pausa no conectado")
	else:
		if panel.process_mode != Node.PROCESS_MODE_ALWAYS:
			fallos.append("panel_pausa no está en PROCESS_MODE_ALWAYS (%s)" % panel.process_mode)
		await _pulsar_p()
		if not get_tree().paused:
			fallos.append("tecla pausa no activó la pausa")
		if not panel._vista.visible:
			fallos.append("vista del panel no visible al pausar")
		if not panel._continuar.can_process():
			fallos.append("botón no procesa estando en pausa")
		await _pulsar_p()
		if get_tree().paused:
			fallos.append("tecla pausa no despausó")
		var nivel_anterior: Node = escena._nivel_instanciado
		panel._pausar()
		panel._reiniciar.pressed.emit()
		if get_tree().paused:
			fallos.append("reiniciar no desactivó la pausa")
		await get_tree().process_frame
		await get_tree().process_frame
		if escena._nivel_instanciado == nivel_anterior:
			fallos.append("reiniciar desde pausa no recreó el nivel")
		panel._pausar()
		panel._continuar.pressed.emit()
		if get_tree().paused:
			fallos.append("continuar no desactivó la pausa")
		if panel._vista.visible:
			fallos.append("vista del panel visible tras continuar")

	# --- Escena final: estadísticas + reset ---
	escena.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	ControladorGlobal.nivel = 3
	ControladorGlobal.muertes = 7
	var final_scene: Node = load("res://Escenas/escena_final/escena_final.tscn").instantiate()
	add_child(final_scene)
	await get_tree().process_frame
	if ControladorGlobal.nivel != 0 or ControladorGlobal.muertes != 0:
		fallos.append("escena_final no reinició la partida")
	var label_muertes: Label = final_scene.get("label_muertes")
	if label_muertes == null or label_muertes.text != "Muertes: 7":
		fallos.append("estadísticas incorrectas: %s" % label_muertes.text)

	final_scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_finalizar(fallos)

func _pulsar_p() -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_P
	ev.pressed = true
	Input.parse_input_event(ev)
	await get_tree().process_frame
	var evr := InputEventKey.new()
	evr.physical_keycode = KEY_P
	evr.pressed = false
	Input.parse_input_event(evr)
	await get_tree().process_frame

func _finalizar(fallos: Array[String]) -> void:
	if fallos.is_empty():
		print("FASE_D_OK")
		get_tree().quit(0)
	else:
		for f in fallos:
			printerr("FAIL: " + f)
		get_tree().quit(1)