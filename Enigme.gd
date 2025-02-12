extends Control

var reponseButton
var reponse

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reponseButton = $Reponse
	#reponse.pressed.connect(self.OnSubmit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	


func _on_reponse_text_submitted(new_text: String) -> void:
	reponse = reponseButton.text
