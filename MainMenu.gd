extends Control

var playButton
var optionsButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playButton = $PlayButton
	playButton.pressed.connect(self.OnPlayButtonClick)
	playButton.grab_focus()
	optionsButton = $OptionsButton
	optionsButton.pressed.connect(self.OnOptionsButtonClick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnPlayButtonClick() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_room.tscn")

func OnOptionsButtonClick() -> void:
	pass#get_tree().change_scene("res://Scenes/game_room.tscn")
