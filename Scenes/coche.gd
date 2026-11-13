extends CharacterBody2D

const VEL_MAX := 400.0
const VEL_MAX_FUERA := 120.0
const ACELERACION := 300.0
const GIRO := 2.5

const SENSOR_ANGULOS := [-60.0, -30.0, 0.0, 30.0, 60.0]  # grados
const SENSOR_LARGO := 150.0
const PASO := 10.0

const ASFALTO_CLARO := true  # pon false si en tu máscara el asfalto es oscuro

@export var mascara_tex: Texture2D

var velocidad := 0.0
var mascara: Image = null

@onready var circuito: Sprite2D = get_node("../Circuito/Sprite2D")


func _ready() -> void:
	if mascara_tex == null:
		push_error("Falta asignar la mascara en el Inspector del Coche")
		return
	mascara = mascara_tex.get_image()
	if mascara.is_compressed():
		mascara.decompress()


func esta_en_asfalto(pos: Vector2) -> bool:
	if mascara == null:
		return true
	var tam_tex := circuito.texture.get_size()
	var local := circuito.to_local(pos)
	if circuito.centered:
		local += tam_tex / 2.0
	var p := local * Vector2(mascara.get_size()) / tam_tex
	var x := int(p.x)
	var y := int(p.y)
	if x < 0 or y < 0 or x >= mascara.get_width() or y >= mascara.get_height():
		return false
	var claro := mascara.get_pixel(x, y).r > 0.5
	return claro == ASFALTO_CLARO


func distancia_libre(ang: float) -> float:
	var dir := Vector2.RIGHT.rotated(rotation + ang)
	var d := 0.0
	while d < SENSOR_LARGO:
		if not esta_en_asfalto(global_position + dir * (d + PASO)):
			break
		d += PASO
	return d


func _physics_process(delta: float) -> void:
	var vel_max := VEL_MAX if esta_en_asfalto(global_position) else VEL_MAX_FUERA

	# Mirar hacia dónde hay más pista libre
	var suma := 0.0
	var peso := 0.0
	for a in SENSOR_ANGULOS:
		var rad := deg_to_rad(a)
		var d := distancia_libre(rad)
		suma += rad * d * d
		peso += d * d

	if peso > 0.0:
		var objetivo := suma / peso
		rotation += clampf(objetivo * 3.0, -GIRO, GIRO) * delta
	else:
		rotation += GIRO * delta  # perdido: gira hasta encontrar asfalto

	# Frenar un poco si hay curva cerca
	var libre := distancia_libre(0.0) / SENSOR_LARGO
	var vel_objetivo := vel_max * clampf(libre, 0.35, 1.0)
	velocidad = move_toward(velocidad, vel_objetivo, ACELERACION * delta)

	velocity = Vector2.RIGHT.rotated(rotation) * velocidad
	move_and_slide()
