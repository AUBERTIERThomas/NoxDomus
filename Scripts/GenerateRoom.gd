extends Node3D

var fullTextList = ["res://Images/ComfyUI_WallSpider.png","res://Images//Photo_moi.JPG","res://Images//map3.jpg"]
var wall1
var wall2
var wall3
var wall4
var ceiling = "res://Images//Photo_moi.JPG"
var ground = "res://Images//CSR.png"
var texture
var childList
var textList

var mainUI
var minimap
var roomListNode
var roomList
var inventory
var inventoryNone
var qcm
var qopen
var reMenu
var reTP
var reWDoom
var reLDoom
var keyMenu
var winMenu
var loseMenu

var currentRoom
var numberOfKeys = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	childList = [$Mur1, $Mur2, $Mur3, $Mur4, $Plafond, $Sol]
	
	mainUI = $MainUI
	minimap = $MainUI/Minimap
	roomListNode = $MainUI/Minimap/RoomList
	roomList = roomListNode.roomList
	inventory = $Inventaire
	inventoryNone = $Inventaire/Obj_None
	qcm = $QCM_Menu
	qopen = $Enigme_Menu
	reMenu = $RandomEvent_Menu
	reTP = $RE_TP
	reWDoom = $RE_WinDoom
	reLDoom = $RE_LoseDoom
	keyMenu = $KeyRoom_Menu
	winMenu = $Win_Menu
	loseMenu = $Lose_Menu
	room_init(0)

func room_init(id : int) -> void:
	print("nouvelle salle")
	currentRoom = roomList[id]
	var s = fullTextList.size()
	wall1 = fullTextList[randi() % s]
	wall2 = fullTextList[randi() % s]
	wall3 = fullTextList[randi() % s]
	wall4 = fullTextList[randi() % s]
	textList = [wall1, wall2, wall3, wall4, ceiling, ground]
	for i in range(6):
		apply_texture(i)
	mainUI.hide()
	inventory.show()
	inventoryNone.grab_focus()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func apply_texture(id: int) -> void:
	var image = Image.new()
	image.load(textList[id])
	var tex = ImageTexture.create_from_image(image)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = tex
	childList[id].set_surface_override_material(0, mat)
	pass


func _on_main_ui_change_room(id : int) -> void:
	currentRoom = roomList[id]
	room_init(id)
	pass # Replace with function body.


func _on_inventaire_obj_done() -> void:
	if mainUI.doomBar.value >= 100:
		loseMenu.show()
	else :
		match currentRoom.typeRoom:
			-3:
				if currentRoom.extraData == 0:
					keyMenu.show()
					await get_tree().create_timer(1.5).timeout
					keyMenu.hide()
					numberOfKeys += 1
					currentRoom.extraData = 1
					mainUI.show()
				else :
					mainUI.show()
			-2:
				if numberOfKeys >= 3:
					winMenu.show()
				else :
					mainUI.show()
			0:
				await get_tree().create_timer(1.0).timeout
				var typeQuestion = randi() % 100
				if typeQuestion < 20 :
					qopen.show()
				else :
					qcm.show()
			1:
				reMenu.show()
				await get_tree().create_timer(2.0).timeout
				reMenu.hide()
				var typeEvent = randi() % 100
				if typeEvent < 30 : # Téléportation aléatoire
					reTP.show()
					var newRoom = roomList[randi() % roomListNode.roomNumber].coordinates
					#print(newRoom)
					await get_tree().create_timer(1.5).timeout
					reTP.hide()
					mainUI.FindNextRoom(1,newRoom)
				elif typeEvent < 50 :
					mainUI.doomBar.value += 5
					mainUI.doomBarValue.text = str(mainUI.doomBar.value)
					reWDoom.show()
					await get_tree().create_timer(1.5).timeout
					reWDoom.hide()
					mainUI.show()
				elif typeEvent < 70 :
					mainUI.doomBar.value -= 5
					mainUI.doomBarValue.text = str(mainUI.doomBar.value)
					reLDoom.show()
					await get_tree().create_timer(1.5).timeout
					reLDoom.hide()
					mainUI.show()
				else :
					mainUI.show()
			_: # Cas général (si une salle n'est pas programmée)
				mainUI.show()
	pass # Replace with function body.
