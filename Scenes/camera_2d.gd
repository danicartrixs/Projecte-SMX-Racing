extends Camera2D

@export var zoom_deseado := 0.6   # más bajo = ves más circuito

var circuito: Sprite2D

func _ready():
	circuito = _buscar_circuito()
	if circuito == null:
		push_error("No encuentro ningún Sprite2D con textura en la escena.")
		return
	print("Circuito encontrado: ", circuito.name)

	enabled = true
	ignore_rotation = true
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	make_current()
	get_viewport().size_changed.connect(_ajustar)
	_ajustar()

func _buscar_circuito() -> Sprite2D:
	var mejor: Sprite2D = null
	var mayor := 0.0
	for n in get_tree().current_scene.find_children("*", "Sprite2D", true, false):
		var s := n as Sprite2D
		if s.texture == null:
			continue
		var t := s.texture.get_size() * s.scale.abs()
		if t.x * t.y > mayor:
			mayor = t.x * t.y
			mejor = s
	return mejor

func _ajustar():
	var size: Vector2 = circuito.texture.get_size() * circuito.scale.abs()
	var origen: Vector2 = circuito.global_position
	if circuito.centered:
		origen -= size / 2.0

	limit_left = int(origen.x)
	limit_top = int(origen.y)
	limit_right = int(origen.x + size.x)
	limit_bottom = int(origen.y + size.y)

	var vp := get_viewport_rect().size
	var z_min := maxf(vp.x / size.x, vp.y / size.y)
	var z := maxf(zoom_deseado, z_min)
	zoom = Vector2(z, z)
