const SENSOR_ANGULOS := [-60.0, -30.0, 0.0, 30.0, 60.0]  # grados
const SENSOR_LARGO := 150.0
const PASO := 10.0


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
