extends Control

# Références aux nœuds
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_input = $Reponse
@onready var answer_sprite = $AnswerFeedback

var current_question = ""
var correct_answer = ""

var answerSprites = [preload("res://Images//AnswersWait.png"),preload("res://Images//AnswersGood.png"),preload("res://Images//AnswersBad.png")]

func _ready():
	answer_sprite.texture = answerSprites[0]  # Point d'interrogation par défaut (pour dire qu'on a rien mis)
	http_request.request_completed.connect(_on_request_completed)
	answer_input.text_submitted.connect(on_button_pressed)
	
	fetch_riddle()

# Executer le code python api.py
func fetch_riddle():
	var url = "http://127.0.0.1:5000/riddle/1"
	print(url)
	http_request.request(url)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Si la requête réussit
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json and "question" in json and "answer" in json:
			# Stocker la question et la bonne réponse
			current_question = json["question"]
			correct_answer = json["answer"]
			
			# La question est dans QuestionPanel/TextEdit
			question_display.text = current_question
			
			# Réinitialisation
			answer_input.text = ""
			print("Bonne réponse attendue : ", correct_answer)
		else:
			question_display.text = "Erreur lors de la récupération de l'énigme."
	else:
		question_display.text = "Erreur de requête : %d" % response_code

# Appelé lorsque l'utilisateur appuie sur "Entrée" = ui_text_submit par défaut
func on_button_pressed(user_answer: String):
	user_answer = user_answer.strip_edges()  # Supprime les espaces 
	if user_answer == correct_answer:
		answer_sprite.texture = answerSprites[1]  # Vart si correct
	else:
		answer_sprite.texture = answerSprites[2]  # Rouge si incorrect
	await get_tree().create_timer(3.0).timeout # C'est un wait
	get_node("/root/Node3D/MainUI").show()
	self.hide()
