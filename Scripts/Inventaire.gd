extends Control

var objList
var leList
var nbList
var objNone

var objUsed

signal objDone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	objList = [$Obj_1, $Obj_2, $Obj_3, $Obj_4, $Obj_5, $Obj_6, $Obj_7, $Obj_8, $Obj_9]
	leList = [$Obj_1/LE_1, $Obj_2/LE_2, $Obj_3/LE_3, $Obj_4/LE_4, $Obj_5/LE_5, $Obj_6/LE_6, $Obj_7/LE_7, $Obj_8/LE_8, $Obj_9/LE_9]
	nbList = [1, 0, 0, 0, 0, 1, 0, 1, 0] #À modifier
	objNone = $Obj_None
	objNone.pressed.connect(OnNoneButtonClick)
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
	emit_signal("objDone")
	self.hide()

func OnNoneButtonClick():
	emit_signal("objDone")
	self.hide()
