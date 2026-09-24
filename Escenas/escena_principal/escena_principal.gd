extends Node2D

@export var niveles: Array[PackedScene]
@export var controlador_partida: ControladorPartida
@export var hud_monedas: HudMonedas
@export var panel_pausa: PanelPausa
var _nivel_actual: int = 0
var _nivel_instanciado: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if panel_pausa != null:
		panel_pausa.reiniciar_solicitado.connect(reiniciar_nivel)
		panel_pausa.salir_solicitado.connect(salir_al_menu)
	if ControladorGlobal.nivel > 1:
		_cargar_nivel()
	else:
		_crear_nivel(_nivel_actual)
	
		
func _crear_nivel(numero_nivel: int)  -> void:
	_nivel_instanciado = niveles[numero_nivel].instantiate()
	add_child(_nivel_instanciado)
	
	var personaje := _buscar_en_grupo(_nivel_instanciado, "personajes")
	if personaje != null and personaje.has_signal("personaje_muerto"):
		personaje.connect("personaje_muerto", _reiniciar_nivel)
	var contenedor := _buscar_en_grupo(_nivel_instanciado, "contenedor_monedas")
	if contenedor != null and contenedor.has_signal("completado"):
		contenedor.connect("completado", siguiente_nivel)
	if hud_monedas != null:
		if contenedor != null and contenedor.has_signal("progreso"):
			contenedor.connect("progreso", hud_monedas.actualizar)
			hud_monedas.iniciar(contenedor.total_monedas())
			hud_monedas.visible = true
		else:
			hud_monedas.visible = false
	ControladorGlobal.nivel = numero_nivel
	controlador_partida.guardar_partida()

func _buscar_en_grupo(root: Node, grupo: String) -> Node:
	if root.is_in_group(grupo):
		return root
	for hijo in root.get_children():
		var encontrado := _buscar_en_grupo(hijo, grupo)
		if encontrado != null:
			return encontrado
	return null

func salir_al_menu() -> void:
	get_tree().change_scene_to_file("res://Escenas/menu_principal/menu_principal.tscn")

func reiniciar_nivel() -> void:
	_reiniciar_nivel()

func _eliminar_nivel():
	_nivel_instanciado.queue_free()
	
func _reiniciar_nivel():
	_eliminar_nivel()
	_crear_nivel.call_deferred(_nivel_actual)
	
func siguiente_nivel():
	_nivel_actual += 1
	_eliminar_nivel()
	_crear_nivel.call_deferred(_nivel_actual)
	
func _cargar_nivel():
	_nivel_actual = ControladorGlobal.nivel
	_crear_nivel.call_deferred(_nivel_actual)
	
