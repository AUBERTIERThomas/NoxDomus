extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.transform.origin = Vector3(-10,-2,0)
	self.scale = Vector3(2,2,2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
