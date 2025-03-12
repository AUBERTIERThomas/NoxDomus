extends Control

# Références aux nœuds
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_input = $Reponse
@onready var answer_sprite = $AnswerFeedback

var current_question = ""
var correct_answer = ""
var user_answer = ""

var answerSprites = [preload("res://Images//AnswersWait.png"),preload("res://Images//AnswersGood.png"),preload("res://Images//AnswersBad.png")]

func _ready():
	answer_sprite.texture = answerSprites[0]  # Point d'interrogation par défaut
	answer_input.text = ""
	http_request.request_completed.connect(_on_riddle_request_completed)
	answer_input.text_submitted.connect(on_button_pressed)
	
	fetch_riddle()

func fetch_riddle():
	var url = "http://127.0.0.1:5000/riddle/generate"
	print(url)
	http_request.request(url)

func _on_riddle_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Si la requête réussit
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json and "question" in json and "answer" in json:
			current_question = json["question"]
			correct_answer = json["answer"]
			question_display.text = current_question
			print("Bonne réponse attendue : ", correct_answer)
		else:
			question_display.text = "Erreur lors de la récupération de l'énigme."
	else: 
		question_display.text = "Erreur de requête : %d" % response_code

func on_button_pressed(user_answer1: String):
	#user_answer1 = user_answer1.strip_edges()  # Supprime les espaces 
	#var url2 = "http://127.0.0.1:5000/riddle/verify?question=%s&correct_answer=%s&user_answer=%s&model=qwen2.5:0.5b" % [current_question.uri_encode(), correct_answer1.uri_encode(), user_answer1.uri_encode()]
	var url2 = "http://127.0.0.1:5000/riddle/verify"
	user_answer = user_answer1
	url2 += "?question=" + current_question.uri_encode() # encodage pour les URL, surtout à cause des caractères spéciaux
	url2 += "&correct_answer=" + correct_answer.uri_encode()
	url2 += "&user_answer=" + user_answer1.uri_encode()
	url2 += "&model=phi3.5" # tester mistral sur une machine avec + de GPU
	print("Réponse de l'utilisateur : ", user_answer1)
	print(url2)
	
	http_request.request_completed.disconnect(_on_riddle_request_completed)
	http_request.request_completed.connect(_on_verify_request_completed)
	http_request.request(url2)

func _on_verify_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and "is_right" in json:
			var is_right = json["is_right"]
			#print(user_answer)
			#print(correct_answer)
			if is_right or user_answer == correct_answer:
				answer_sprite.texture = answerSprites[1] 
				print("Réponse correcte")
				# il y a des modèles qui n'arrivent meme pas à voir que c'est == de temps en temps ...
				if not is_right: print("modèle bizarre") 
			else:
				answer_sprite.texture = answerSprites[2]
				print("Réponse incorrecte")
		else:
			print("Erreur fichier json")
	else:
		print("Erreur de requête (vérification) : %d" % response_code)
	
	await get_tree().create_timer(3.0).timeout
	get_node("/root/Node3D/MainUI").show()
	answer_sprite.texture = answerSprites[0]
	self.hide()
