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

# Une fois les infos du menu PlayerInfos validés avec "OK !", génère une image de mur. Le contenu des champs est alors pris en compte.
func OnOKButtonClick() -> void:
	fearPrompt = fearTextEdit.text
	
	# Génération d'une image de mur
	var url = "http://127.0.0.1:5000/image/generate"
	url += "?name=_Wall1"
	url += "&output_folder=Images/"
	print(url)
	
	http_request.request_completed.connect(_on_imgen_request_completed)
	http_request.request(url)

# Génère X variantes du mur généré au-dessus, puis lance le jeu.
func _on_imgen_request_completed() -> void:
	# Génération d'une variante de l'image de mur (générée précédemment)
	for i in range(4): # On en fait 4, mais on peut changer
		var url = "http://127.0.0.1:5000/image/inpaint"
		url += "?img_path=Images/_Wall1"
		url += "&mask_path=AI/Images/masks/mask"+str(randi()%5 + 1)+".png"
		url += "&positive_prompt="+fearPrompt
		url += "&filename=_Wall1_"+str(i)
		url += "&output_folder=Images/"
		print(url)
		http_request.request(url)
		await http_request.request_completed
	
	# Chargement de la scène principale du jeu
	get_tree().change_scene_to_file("res://Scenes/game_room.tscn")
