extends Control
#---------------------------------------------------------------------------------
# Gère la communication entre l'API api.py et le menu d'énigme.
# Cela comprend récupérer une énigme, évaluer la réponse du joueur avec un modèle
# d'IA et agir en conséquence.
#---------------------------------------------------------------------------------
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_input = $Reponse
@onready var answer_sprite = $AnswerFeedback
@onready var inventory = get_node("/root/Node3D/Inventaire")
@onready var mainUI = get_node("/root/Node3D/MainUI")
@onready var commentary_display = get_node("/root/Node3D/MainUI/CommentaryPanel")
@onready var commentary_text = get_node("/root/Node3D/MainUI/CommentaryPanel/TextEdit")

var current_question = ""
var correct_answer = ""
var user_answer = ""
var isShown = false

# Sprites pour l'état de la réponse (en attente/bonne/fausse).
var answerSprites = [preload("res://Images//AnswersWait.png"),preload("res://Images//AnswersGood.png"),preload("res://Images//AnswersBad.png")]

func _ready():
	answer_sprite.texture = answerSprites[0]  # Point d'interrogation par défaut.
	answer_input.text = ""
	answer_input.text_submitted.connect(on_button_pressed) # Déclenche la fonction lorsqu'on appuie sur "Entree" dans le LineEdit.
	
	fetch_riddle()

# Demande une énigme de la base, lance la fonction suivante une fois la requête finie.
func fetch_riddle():
	var url = "http://127.0.0.1:5000/riddle/generate"
	print(url)
	http_request.request_completed.connect(_on_riddle_request_completed)
	http_request.request(url)

# Récupère l'énigme et la réponse.
func _on_riddle_request_completed(_result, response_code, _headers, body):
	if response_code == 200:  # Si la requête réussit
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json and "question" in json and "answer" in json:
			current_question = json["question"].uri_decode()
			correct_answer = json["answer"].uri_decode()
			question_display.text = current_question
			print("Bonne réponse attendue (énigme) : ", correct_answer)
		else:
			question_display.text = "Erreur lors de la récupération de l'énigme."
	else: # Survient notamment si l'API n'est pas lançée.
		question_display.text = "Erreur de requête (énigme): %d" % response_code

# Lorsque le joueur envoie sa réponse. Demande à l'IA si la réponse est correcte, lance la fonction suivante une fois la requête finie.
func on_button_pressed(user_answer1: String):
	var url2 = "http://127.0.0.1:5000/riddle/verify"
	user_answer = user_answer1
	url2 += "?question=" + current_question.uri_encode() # Encodage pour les URL, surtout à cause des caractères spéciaux.
	url2 += "&correct_answer=" + correct_answer.uri_encode()
	url2 += "&user_answer=" + user_answer1.uri_encode()
	url2 += "&model=phi3.5" 
	print("Réponse de l'utilisateur : ", user_answer1)
	print(url2)
	
	http_request.request_completed.disconnect(_on_riddle_request_completed)
	http_request.request_completed.connect(_on_verify_request_completed)
	http_request.request(url2)

# Récupère le résultat de l'IA et le met en application.
func _on_verify_request_completed(_result, response_code, _headers, body):
	var res
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and "is_right" in json:
			var is_right = json["is_right"]
			
			res = (is_right or user_answer == correct_answer)
			# Bonne réponse
			if res:
				answer_sprite.texture = answerSprites[1] 
				print("Réponse correcte")
				# Don d'objet
				var ggg = randi() % 5
				print(ggg)
				inventory.nbList[ggg] += 1
				inventory.leList[ggg].text = str(inventory.nbList[ggg])
				inventory.objList[ggg].disabled = false
				# Il y a des modèles qui n'arrivent meme pas à voir que c'est == de temps en temps ...
				if not is_right: print("modèle bizarre") # Je ne cautionne pas
			
			# Mauvaise réponse
			else:
				answer_sprite.texture = answerSprites[2]
				mainUI.doomBar.value += 3
				mainUI.doomBarValue.text = str(mainUI.doomBar.value)
				print("Réponse incorrecte")
		else:
			print("Erreur fichier json")
	else:
		print("Erreur de requête (vérification) : %d" % response_code)
	
	await get_tree().create_timer(3.0).timeout
	get_node("/root/Node3D/MainUI").show()
	answer_sprite.texture = answerSprites[0]
	answer_input.text = ""
	fetch_commentary(res)
	#fetch_riddle() # Demande à préparer la prochaine énigme.
	self.hide()
	
func fetch_commentary(res: bool):
	commentary_display.show()
	var url = "http://127.0.0.1:5000/alexandre/astier"
	url += "?question=" + current_question.uri_encode()
	url += "&correct_answer=" + correct_answer.uri_encode()
	url += "&user_answer=" + user_answer.uri_encode()
	url += "&is_user_right=" + str(res).to_lower()
	url += "&model=phi3.5"

	print("Requête commentaire : ", url)

	http_request.request_completed.disconnect(_on_verify_request_completed)
	http_request.request_completed.connect(_on_commentary_request_completed)
	http_request.request(url)

func _on_commentary_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and "response" in json:
			var comment = json["response"]
			commentary_text.text = comment
			print("Commentaire :", comment)
		else:
			commentary_text.text = "Erreur lors de la récupération du commentaire."
	else:
		commentary_text.text = "Erreur de requête (commentaire) : %d" % response_code
	http_request.request_completed.disconnect(_on_commentary_request_completed)
	await get_tree().create_timer(3.0).timeout
	fetch_riddle() # Nouvel énigme
