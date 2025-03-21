extends Control

var objList
var leList
var nbList
var objNone

var objUsed
var objData

var mainUI
var roomList
var doomBar
var doomBarValue

signal objDone
signal obj2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	objList = [$Obj_1, $Obj_2, $Obj_3, $Obj_4, $Obj_5, $Obj_6, $Obj_7, $Obj_8, $Obj_9]
	leList = [$Obj_1/LE_1, $Obj_2/LE_2, $Obj_3/LE_3, $Obj_4/LE_4, $Obj_5/LE_5, $Obj_6/LE_6, $Obj_7/LE_7, $Obj_8/LE_8, $Obj_9/LE_9]
	nbList = [1, 10, 0, 0, 0, 0, 0, 0, 0] #À modifier
	objNone = $Obj_None
	objNone.pressed.connect(OnNoneButtonClick)
	mainUI = get_node("/root/Node3D/MainUI")
	roomList = get_node("/root/Node3D/MainUI/Minimap/RoomList").roomList
	doomBar = get_node("/root/Node3D/MainUI/DoomBar")
	doomBarValue = get_node("/root/Node3D/MainUI/DoomBarValue")
	for i in range(9):
		objList[i].pressed.connect(OnObjButtonClick.bind(i))
		leList[i].text = str(nbList[i])
		if (!nbList[i]): #Si le joueur n'a pas l'objet, on désactive le bouton
			objList[i].disabled = true

func OnObjButtonClick(id : int):
	print("le bouton")
	objUsed = objList[id]
	nbList[id] = nbList[id] - 1 #Ça utilise l'objet
	leList[id].text = str(nbList[id])
	if (!nbList[id]): #Si le joueur n'a pas l'objet, on désactive le bouton
		objList[id].disabled = true
	
	match id:
		0: # -5 de malédiction
			print("Objet 1")
			doomBar.value -= 5
			doomBarValue.text = str(doomBar.value)
		1:
			print("Objet 2")
			for i in range(roomList.size()):
				if roomList[i].isRevealed == false:
					get_node("/root/Node3D/MainUI/Minimap/"+str(i)).disabled = false
			
			await obj2
			get_node("/root/Node3D/MainUI/Minimap/"+str(objData)).isRevealed = true
			for i in range(roomList.size()):
				get_node("/root/Node3D/MainUI/Minimap/"+str(i)).disabled = true
	emit_signal("objDone")
	self.hide()

func OnNoneButtonClick():
	emit_signal("objDone")
	self.hide()

func _on_minimap_room_chosen(id : int) -> void:
	objData = id
	emit_signal("obj2")
	pass # Replace with function body.
