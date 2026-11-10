extends PathFollow2D

var velocidad := 200.0

func _process(delta):
	progress += velocidad * delta
