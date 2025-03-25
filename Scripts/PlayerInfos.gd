extends Control
#---------------------------------------------------------------------------------
# Gère la fiche d'information du joueur.
# Appelle l'API de génération d'image.
#---------------------------------------------------------------------------------
@onready var http_request = $HTTPRequest

var okButton
var fearTextEdit
var fearPrompt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	okButton = $OK
	okButton.pressed.connect(self.OnOKButtonClick)
	fearTextEdit = $PeursLE
	pass

# Une fois les infos du menu PlayerInfos validés avec "OK !", génère X images de mur. Le contenu des champs est alors pris en compte.
func OnOKButtonClick() -> void:
	okButton.disabled = true
	fearPrompt = fearTextEdit.text
	
	for i in range(2): # On en fait 4, mais on peut changer
		var prefix = "http://127.0.0.1:5000/image/inpaint?"
		var url = ""
		url += "img_path=Images/_Wall0.png"
		url += "&mask_path=AI/Images/masks/mask"+str(randi()%5 + 1)+".png"
		url += "&positive_prompt="+fearPrompt.uri_encode()
		url += "&filename=_Wall0_"+str(i)
		url += "&output_folder=Images/"
		url = prefix + url
		print(url)
		http_request.request(url)
		await http_request.request_completed
	
	# Chargement de la scène principale du jeu
	get_tree().change_scene_to_file("res://Scenes/game_room.tscn")
