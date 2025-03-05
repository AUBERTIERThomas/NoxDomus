extends Control

var okButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	okButton = $OK
	okButton.pressed.connect(self.OnOKButtonClick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnOKButtonClick() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_room.tscn")
