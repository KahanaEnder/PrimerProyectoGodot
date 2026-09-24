extends Node

const TILE_SET := "res://tile_sets/mazmorra.tres"
const TILE_FONDO := Vector2i(0, 3)
const TILE_SOLIDO := Vector2i(0, 0)
const TAM_TILE := 16

const MAPA: Array[String] = [
	"##############################",
	"#............................#",
	"#..................T.........#",
	"#............................#",
	"#............................#",
	"#............................#",
	"#.....C.......C.......C......#",
	"#............................#",
	"#..P......SS.............E...#",
	"##############################",
]

const ESCENAS := {
	"P": "res://personaje/personaje.tscn",
	"C": "res://Escenas/moneda/moneda.tscn",
	"S": "res://Escenas/pinchos/pinchos.tscn",
	"E": "res://Escenas/enemigo/enemigo.tscn",
	"T": "res://Escenas/trampa/trampa.tscn",
}

const NOMBRES := {
	"P": "Personaje",
	"C": "Moneda",
	"S": "Pinchos",
	"E": "Enemigo",
	"T": "Trampa",
}

func _ready() -> void:
	var tile_set: TileSet = load(TILE_SET)
	var recursos := {}
	for clave in ESCENAS:
		recursos[clave] = load(ESCENAS[clave])

	var nivel := Node2D.new()
	nivel.name = "Nivel3"

	var fondo := TileMapLayer.new()
	fondo.name = "Fondo"
	fondo.z_index = -1
	fondo.tile_set = tile_set
	nivel.add_child(fondo)
	fondo.owner = nivel

	var capa := TileMapLayer.new()
	capa.name = "Nivel"
	capa.tile_set = tile_set
	nivel.add_child(capa)
	capa.owner = nivel

	var bordes: Node = load("res://Escenas/bordes/bordes.tscn").instantiate()
	nivel.add_child(bordes)
	bordes.owner = nivel

	var contenedor: Node = load("res://Escenas/contenedor_monedas/contenedor_monedas.tscn").instantiate()
	contenedor.name = "ContenedorMonedas"
	nivel.add_child(contenedor)
	contenedor.owner = nivel

	var altura := MAPA.size()
	var contadores := {}
	for y in altura:
		var fila: String = MAPA[y]
		for x in fila.length():
			var celda := fila[x]
			var mundo := Vector2(x * TAM_TILE + 8.0, y * TAM_TILE + 8.0)
			var fondo_cerda: Vector2i = TILE_FONDO
			match celda:
				"#":
					capa.set_cell(Vector2i(x, y), 0, TILE_SOLIDO)
				".":
					pass
				_:
					var instancia: Node2D = recursos[celda].instantiate()
					instancia.position = mundo
					contadores[celda] = contadores.get(celda, 0) + 1
					var numero: int = contadores[celda]
					var base_nombre: String = NOMBRES[celda]
					instancia.name = base_nombre if numero == 1 else base_nombre + str(numero)
					if celda == "C":
						contenedor.add_child(instancia)
					else:
						nivel.add_child(instancia)
					instancia.owner = nivel
			fondo.set_cell(Vector2i(x, y), 0, fondo_cerda)

	var paquete := PackedScene.new()
	print("HIJOS=", nivel.get_child_count())
	var err := paquete.pack(nivel)
	print("PACK=", err)
	DirAccess.make_dir_recursive_absolute("res://Escenas/nivel_3")
	err = ResourceSaver.save(paquete, "res://Escenas/nivel_3/nivel_3.tscn")
	print("SAVE=", err)
	get_tree().quit(0)