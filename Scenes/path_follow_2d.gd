extends PathFollow2D

@export var velocidad := 200.0

func _process(delta: float) -> void:
	progress += velocidad * delta
