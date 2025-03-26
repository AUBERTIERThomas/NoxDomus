extends Control
#---------------------------------------------------------------------------------
# Gère la communication entre l'API api.py et le menu de QCM.
# Cela comprend récupérer un QCM, vérifier si la réponse du joueur est la bonne et
# agir en conséquence.
#---------------------------------------------------------------------------------
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_button = [$A,$B,$C,$D]
@onready var answer_sprite = $AnswerFeedback
@onready var inventory = get_node("/root/Node3D/Inventaire")
@onready var mainUI = get_node("/root/Node3D/MainUI")
@onready var commentary_display = get_node("/root/Node3D/MainUI/CommentaryPanel")
@onready var commentary_text = get_node("/root/Node3D/MainUI/CommentaryPanel/TextEdit")

var current_question = ""
var correct_answer = ""
var incorrect_answers
var correct_answer_id

var answerSprites = [preload("res://Images//AnswersGood.png"),preload("res://Images//AnswersBad.png")]

func _ready():
	answer_sprite.texture = null
	http_request.request_completed.connect(_on_riddle_request_completed)
	for i in range(4):
		answer_button[i].pressed.connect(on_button_pressed.bind(i))
	
	fetch_riddle()

# Demande un QCM de la base, lance la fonction suivante une fois la requête finie.
func fetch_riddle():
	var url = "http://127.0.0.1:5000/qcm/generate"
	print(url)
	http_request.request_completed.disconnect(_on_commentary_request_completed)
	http_request.request_completed.connect(_on_riddle_request_completed)
	http_request.request(url)

# Récupère le QCM et les réponses. Identifie la bonne parmi les 4, puis les place aléatoirement sur les boutons.
func _on_riddle_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Si la requête réussit
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json and "question" in json and "correct_answer" in json and "incorrect_answers" in json:
			current_question = json["question"].uri_decode()
			correct_answer = json["correct_answer"].uri_decode()
			incorrect_answers = json["incorrect_answers"]
			for inc in incorrect_answers.size():
				incorrect_answers[inc] = incorrect_answers[inc].uri_decode()
			question_display.text = current_question
			var ra
			for i in range(4):
				ra = [0,1,2,3]
				ra.shuffle()
			for i in range(4):
				if ra[i] == 3:
					answer_button[i].text = correct_answer
					correct_answer_id = i
				else :
					answer_button[i].text = incorrect_answers[ra[i]]
			print("Bonne réponse attendue (QCM) : ", correct_answer)
		else:
			question_display.text = "Erreur lors de la récupération du QCM."
	else: 
		question_display.text = "Erreur de requête (QCM) : %d" % response_code

# Lorsque le joueur envoie sa réponse, en déduit le résultat (bon/faux) et le met en application.
func on_button_pressed(id: int):
	if id == correct_answer_id:
		answer_sprite.texture = answerSprites[0]  # Vart si correct
		# Don d'objet
		var ggg = randi() % 5
		print(ggg)
		inventory.nbList[ggg] += 1
		inventory.leList[ggg].text = str(inventory.nbList[ggg])
		inventory.objList[ggg].disabled = false
	else:
		answer_sprite.texture = answerSprites[1]  # Rouge si incorrect
		mainUI.doomBar.value += 1
		mainUI.doomBarValue.text = str(mainUI.doomBar.value)

	answer_button[correct_answer_id].disabled = true
	await get_tree().create_timer(3.0).timeout
	get_node("/root/Node3D/MainUI").show()
	answer_sprite.texture = null # Cache l'indicateur du résultat.
	answer_button[correct_answer_id].disabled = false
	#fetch_commentary(id == correct_answer_id, id)
	fetch_riddle()
	self.hide()

func fetch_commentary(res: bool, ans_id : int):
	commentary_display.show()
	var url = "http://127.0.0.1:5000/alexandre/astier"
	url += "?question=" + current_question.uri_encode()
	url += "&correct_answer=" + correct_answer.uri_encode()
	url += "&user_answer=" + answer_button[ans_id].text.uri_encode()
	url += "&is_user_right=" + str(res).to_lower()
	url += "&model=phi3.5"

	print("Requête commentaire :", url)

	http_request.request_completed.disconnect(_on_riddle_request_completed)
	http_request.request_completed.connect(_on_commentary_request_completed)
	http_request.request(url)

func _on_commentary_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and "response" in json:
			var comment = json["response"]
			commentary_text.text = comment.uri_decode()
			print("Commentaire :", comment)
		else:
			commentary_text.text = "Erreur lors de la récupération du commentaire."
	else:
		commentary_text.text = "Erreur de requête (commentaire) : %d" % response_code
