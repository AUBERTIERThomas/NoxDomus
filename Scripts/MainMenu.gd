extends Control
#---------------------------------------------------------------------------------
# Gère le menu pricipal (avant le déroulé du jeu).
#---------------------------------------------------------------------------------
var playButton
var optionsButton

var playerInfos

func _ready() -> void:
	playButton = $PlayButton
	playButton.pressed.connect(self.OnPlayButtonClick)
	playButton.grab_focus()
	optionsButton = $OptionsButton
	optionsButton.pressed.connect(self.OnOptionsButtonClick)
	pass # Replace with function body.

# Bouton "Jouer" (voir PlayerInfos.gd).
func OnPlayButtonClick() -> void:
	self.hide()
	get_node("/root/MainMenu/PlayerInfos").show()

# Bouton "Options" (pas utilisé).
func OnOptionsButtonClick() -> void:
	pass
