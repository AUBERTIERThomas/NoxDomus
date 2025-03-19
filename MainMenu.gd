extends Control

var playButton
var optionsButton

var playerInfos

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
	self.hide()
	get_node("/root/MainMenu/PlayerInfos").show()

func OnOptionsButtonClick() -> void:
	pass
