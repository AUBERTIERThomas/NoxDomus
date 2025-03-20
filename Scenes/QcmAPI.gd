extends Control

# Références aux nœuds
@onready var http_request = $HTTPRequest
@onready var question_display = $QuestionPanel/TextEdit
@onready var answer_button = [$A,$B,$C,$D]
@onready var answer_sprite = $AnswerFeedback
@onready var inventory = get_node("/root/Node3D/Inventaire")
@onready var mainUI = get_node("/root/Node3D/MainUI")

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

func fetch_riddle():
	var url = "http://127.0.0.1:5000/qcm/generate"
	print(url)
	http_request.request(url)

func _on_riddle_request_completed(result, response_code, headers, body):
	if response_code == 200:  # Si la requête réussit
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json and "question" in json and "correct_answer" in json and "incorrect_answers" in json:
			current_question = json["question"]
			correct_answer = json["correct_answer"]
			incorrect_answers = json["incorrect_answers"]
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

func on_button_pressed(id: int):
	if id == correct_answer_id:
		answer_sprite.texture = answerSprites[0]  # Vart si correct
		var ggg = randi() % 9
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
	answer_sprite.texture = null
	answer_button[correct_answer_id].disabled = false
	fetch_riddle()
	self.hide()
