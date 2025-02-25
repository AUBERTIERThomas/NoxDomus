extends Control

# Références aux nœuds
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_input = $Reponse
@onready var color_rect = $ColorRect

var current_question = ""
var correct_answer = ""

func _ready():
	color_rect.color = Color(0, 0, 1)  # Bleu par défaut (pour dire qu'on a rien mis)
	http_request.request_completed.connect(_on_request_completed)
	answer_input.text_submitted.connect(on_button_pressed)
	
	fetch_riddle()

# Executer le code python api.py
func fetch_riddle():
	var url = "http://127.0.0.1:5000/riddle/1"
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
			color_rect.color = Color(0, 0, 1)  # Bleu par défaut (pour dire qu'on a rien mis)
			print("Bonne réponse attendue : ", correct_answer)
		else:
			question_display.text = "Erreur lors de la récupération de l'énigme."
	else:
		question_display.text = "Erreur de requête : %d" % response_code

# Appelé lorsque l'utilisateur appuie sur "Entrée" = ui_text_submit par défaut
func on_button_pressed(user_answer: String):
	user_answer = user_answer.strip_edges()  # Supprime les espaces 
	if user_answer == correct_answer:
		color_rect.color = Color(0, 1, 0)  # Vert si correct
	else:
		color_rect.color = Color(1, 0, 0)  # Rouge si incorrect
