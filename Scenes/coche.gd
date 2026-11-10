extends CharacterBody2D

const VEL_MAX := 400.0
const VEL_MAX_FUERA := 120.0
const ACELERACION := 300.0
const FRENADO := 500.0
const ROZAMIENTO := 150.0
const GIRO := 2.5

var velocidad := 0.0
var mascara: Image = null


func _ready() -> void:
	# Carga la máscara solo si existe; si no, todo cuenta como asfalto
	var ruta := "res://circuito/circuito_mascara.png"
	if ResourceLoader.exists(ruta):
		mascara = load(ruta).get_image()
		if mascara.is_compressed():
			mascara.decompress()


func esta_en_asfalto(pos: Vector2) -> bool:
	if mascara == null:
		return true
	var x := int(pos.x)
	var y := int(pos.y)
	if x < 0 or y < 0 or x >= mascara.get_width() or y >= mascara.get_height():
		return false
	return mascara.get_pixel(x, y).r > 0.5


func _physics_process(delta: float) -> void:
	var en_asfalto := esta_en_asfalto(global_position)
	var vel_max := VEL_MAX if en_asfalto else VEL_MAX_FUERA

	if Input.is_action_pressed("ui_up"):
		velocidad += ACELERACION * delta
	elif Input.is_action_pressed("ui_down"):
		velocidad -= FRENADO * delta
	else:
		velocidad = move_toward(velocidad, 0.0, ROZAMIENTO * delta)

	velocidad = clamp(velocidad, -vel_max * 0.4, vel_max)

	var giro := Input.get_axis("ui_left", "ui_right")
	if abs(velocidad) > 5.0:
		rotation += giro * GIRO * delta * sign(velocidad)

	velocity = Vector2.UP.rotated(rotation) * velocidad
	move_and_slide()
