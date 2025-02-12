extends Control

var mapButton
var returnButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapButton = $MapButton
	mapButton.pressed.connect(self.OnMapButtonClick)
	returnButton = $Minimap/Return
	returnButton.pressed.connect(self.OnReturnButtonClick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func OnMapButtonClick() -> void:
	get_node("Minimap").show()

func OnReturnButtonClick() -> void:
	get_node("Minimap").hide()
