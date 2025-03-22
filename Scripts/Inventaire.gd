extends Control
#---------------------------------------------------------------------------------
# Gère l'inventaire, le nombre d'objet et leurs effets.
#---------------------------------------------------------------------------------
var objList
var leList
var nbList
var objNone

var objUsed # Identifiant du type d'objet utilisé
var objData # Donnée supplémentaire utile pour certains objets.
var currentRoom # Salle actuelle.
var freeQuestion # Compteur de question automatiquement validées.
var freeEvent # Compteur d'événements automatiquement passés.

var mainUI
var overlay
var minimap
var roomList
var doomBar
var doomBarValue

signal objDone
signal obj2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	objList = [$Obj_1, $Obj_2, $Obj_3, $Obj_4, $Obj_5, $Obj_6, $Obj_7, $Obj_8, $Obj_9]
	leList = [$Obj_1/LE_1, $Obj_2/LE_2, $Obj_3/LE_3, $Obj_4/LE_4, $Obj_5/LE_5, $Obj_6/LE_6, $Obj_7/LE_7, $Obj_8/LE_8, $Obj_9/LE_9]
	nbList = [1, 1, 1, 1, 1, 0, 0, 0, 0] # À modifier (inventaire non vide pour les tests).
	objNone = $Obj_None
	objNone.pressed.connect(OnNoneButtonClick)
	freeQuestion = 0
	freeEvent = 0
	mainUI = get_node("/root/Node3D/MainUI")
	overlay = get_node("/root/Node3D/MainUI/Overlay")
	minimap = get_node("/root/Node3D/MainUI/Minimap")
	roomList = get_node("/root/Node3D/MainUI/Minimap/RoomList").roomList
	doomBar = get_node("/root/Node3D/MainUI/Overlay/DoomBar")
	doomBarValue = get_node("/root/Node3D/MainUI/Overlay/DoomBarValue")
	for i in range(9):
		objList[i].pressed.connect(OnObjButtonClick.bind(i))
		leList[i].text = str(nbList[i])
		if (!nbList[i]): #Si le joueur n'a pas l'objet, on désactive le bouton
			objList[i].disabled = true

func OnObjButtonClick(id : int):
	objUsed = objList[id]
	nbList[id] = nbList[id] - 1 # Ça utilise l'objet.
	leList[id].text = str(nbList[id])
	# Si le joueur n'a pas l'objet, on désactive le bouton.
	if (!nbList[id]):
		objList[id].disabled = true
	currentRoom = mainUI.currentRoom
	
	match id:
		0: # -5 de malédiction
			print("Objet 1")
			doomBar.value -= 5
			doomBarValue.text = str(doomBar.value)
		1: # Révélation d'une salle encore cachée au choix (en cliquant sur la case).
			print("Objet 2")
			# Sélectionne les salles non révélées.
			for i in range(roomList.size()):
				if roomList[i].isRevealed == false:
					get_node("/root/Node3D/MainUI/Minimap/"+str(i)).disabled = false
			OpenMinimap()
			await obj2
			print(objData)
			# Se téléporte dans la salle à la position "objData" dans la liste des salles. Aucune si -1.
			if objData >= 0:
				roomList[objData].isRevealed = true
				minimap.changeTexture(objData)
				objData = -1
			CloseMinimap()
		2 : # Téléportation dans une salle proche
			print("Objet 3")
			# Sélectionne les salles non révélées.
			for i in range(roomList.size()):
				var dist = currentRoom.coordinates - roomList[i].coordinates
				if abs(dist.x) + abs(dist.y) <= 4:
					get_node("/root/Node3D/MainUI/Minimap/"+str(i)).disabled = false
			OpenMinimap()
			await obj2
			print(objData)
			# Révèle la salle à la position "objData" dans la liste des salles. Aucune si -1.
			if objData >= 0:
				roomList[objData].isRevealed = true
				mainUI.FindNextRoom(1,roomList[objData].coordinates)
				objData = -1
			CloseMinimap()
			mainUI.ShowButtons()
		3 : # Permet de valider automatiquement la prochaine question.
			print("Objet 4")
			freeQuestion += 1
		4 : # Permet de passer automatiquement le prochain événement.
			print("Objet 5")
			freeEvent += 1
	
	mainUI.ShowButtons()
	emit_signal("objDone")
	self.hide()

# Si le joueur ne veut pas utiliser d'objet.
func OnNoneButtonClick():
	emit_signal("objDone")
	self.hide()

# Ouvre la minimap pour activer l'effet d'un objet.
func OpenMinimap():
	self.hide()
	mainUI.show()
	overlay.hide()
	minimap.show()

# Ferme la minimap après l'effet d'un objet. Désactive les boutons.
func CloseMinimap():
	minimap.hide()
	overlay.show()
	mainUI.hide()
	self.show()
	currentRoom = mainUI.currentRoom
	for i in range(roomList.size()):
		get_node("/root/Node3D/MainUI/Minimap/"+str(i)).disabled = true

# Renvoie l'indice de la salle dans la liste des salles (pour les objets concernés).
func _on_minimap_room_chosen(id : int) -> void:
	objData = id
	emit_signal("obj2")
