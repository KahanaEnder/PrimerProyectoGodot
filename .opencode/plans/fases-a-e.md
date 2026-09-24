# Plan de mejora del proyecto "PrimerProyecto" (Godot 4.7.2)

Estrategia: implementación **por fases (A→E)**. Al terminar cada fase: verificar ejecutando
el proyecto y revisando la consola, hacer `git commit + push`, y **pedir permiso** al usuario
antes de pasar a la siguiente.

## Fase A — Robustez y fixes de bugs

**Objetivo:** eliminar acoplamiento frágil a la jerarquía (`get_parent()` encadenado),
arreglar bugs de flujo (progreso guardado al ganar) y conexiones incorrectas.

### A1. `Escenas/moneda/moneda.gd`
- Añadir señal `recogida`.
- `_ready()`: añadir al grupo `"monedas"` y conectar `area2d.body_entered`.
- `_recogida()`: emitir `recogida` y `queue_free()` (sin chain de `get_parent()`).
- `_iniciar_animacion()`: `create_tween().bind_node(self)` para evitar error al liberar el nodo.

### A2. `Escenas/moneda/moneda.tscn`
- Quitar nodo `Sprite2D/ReproductorSonidoMoneda` y sus `ext_resource` (script
  `reproductor_sonido_moneda.gd` y `AudioStream` de moneda).
- Quitar la asignación `reproductor = NodePath(...)` y el `node_paths` correspondiente.
- Conservar `AnimationPlayer` (rotación) y `Area2D` de recogida.

### A3. `Escenas/contenedor_monedas/contenedor_monedas.gd`
- Señal `completado`.
- `_ready()`: `add_to_group("contenedor_monedas")`; recorrer hijos en grupo `"monedas"`,
  conectar `recogida` → `_moneda_recogida(moneda)`; `_total_monedas` = nº de monedas.
- `_moneda_recogida()`: posicionar el reproductor en `moneda.global_position`, reproducir,
  al llegar al total emitir `completado`. **Elimina** `get_parent().get_parent().siguiente_nivel()`.

### A4. `Escenas/contenedor_monedas/contenedor_monedas.tscn`
- Añadir nodo `AudioStreamPlayer2D` con `sonido_moneda.wav`, bus `&"SFX"`.
- Exponer `reproductor` (NodePath).

### A5. `Escenas/escena_principal/escena_principal.gd`
- En `_crear_nivel()`: localizar personaje y contenedor por grupos
  (`get_tree().get_first_node_in_group(...)` + `has_signal`) en vez del bucle de hijos.
- Añadir `salir_al_menu()` → `change_scene_to_file("res://Escenas/menu_principal/menu_principal.tscn")`.

### A6. `Escenas/menu_principal/jugar.gd`
- Reemplazar `pressed.connect(jugar, 4)` (flag CONNECT_ONE_SHOT raro) por `pressed.connect(jugar)`.
- Conservar método público `jugar()` (lo usa `cargar.gd`).

### A7. `Escenas/controlador_partida/controlador_partida.gd`
- Añadir `reiniciar_partida()`: `nivel = 0`, `muertes = 0` y `guardar_partida()`.

### A8. Bug flujo al ganar
- Nueva `Escenas/escena_final/escena_final.gd`: en `_ready()` llamar
  `controlador_partida.reiniciar_partida()` (papel de limpiar progreso).
- `Escenas/escena_final/escena_final.tscn`: instanciar `ControladorPartida` y cablear export;
  obtener UID del script vía MCP antes de referenciarlo.
- Resultado: al ganar, la partida queda limpia → "Jugar" empieza en nivel 1.

### Verificación A
- Ejecutar proyecto (MCP): menú → nivel 1 → recoger monedas (avanza) → morir en trampa
  (reinicia + sube contador) → escena final → volver a "Jugar" (inicia nivel 1).
- `get_debug_output()` sin errores/script warnings críticos.

## Fase B — Game feel del personaje
- `personaje/personaje.gd`: coyote time (~0.12 s), jump buffering (~0.15 s), salto variable
  (soltar = recorte de impulso), aceleración/fricción horizontales, prioridad de animaciones
  (saltar > correr > idle), squash & stretch con Tween. (Se apoya en la skill `platformer`.)
- `Escenas/escena_principal/escena_principal.tscn`: `Camera2D` con `position_smoothing` + límites.
- Verificación: playtest del usuario + consola sin errores.

## Fase C — Contenido y mecánicas
- **C1** Escena `Pinchos` (StaticBody2D capa `Damage` + atlas del tileset).
- **C2** Escena `Enemigo` patrulla (CharacterBody2D, gira en pared/borde; contacto = muerte).
  Visual: sprite del tileset de mazmorra (placeholder).
- **C3** `nivel_3.tscn` generado por script temporal que pinta el `TileMapLayer` desde un mapa
  ASCII (sin editar PackedByteArray a mano); se registra en el array `niveles` de
  escena_principal. El generador se elimina en E.
- **C4** (opcional) Plataforma móvil ida/vuelta.
- Verificación: cargar cada nivel, probar daño púas/enemigo y avance al tercer nivel.

## Fase D — UI / UX
- **Menú de pausa** (CanvasLayer, `PROCESS_MODE_ALWAYS`): Continuar / Reiniciar nivel /
  Volver al menú (tecla P existente).
- **HUD de monedas**: contador recogidas/total por nivel.
- **Escena final pulida**: confeti (GPUParticles2D), estadísticas (muertes), botones
  Volver al menú / Jugar de nuevo.
- **Sonidos placeholder**: tonos WAV sintetizados (salto, muerte, victoria) vía script;
  enrutados al bus `SFX`.
- Verificación: flujo de menús/HUD sin errores.

## Fase E — Higiene final
- Eliminar `Escenas/primera_escena/PrimeraEscena.tscn` (sin referencias, verificado),
  `reproductor_sonido_moneda.gd` y temporales (generador nivel 3).
- Headless `--check` para corregir warnings (tipado).
- Regresión completa menú → niveles → victoria sin errores.

## Reglas generales
- Una fase por viaje; al terminar: verificación + commit + push + pedir permiso.
- Sin commits fuera de las fases salvo que el usuario lo pida.