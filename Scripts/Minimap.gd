extends Control
#---------------------------------------------------------------------------------
# Gère l'affichage de la minimap.
# Associe aux salles les sprites représentant leur type et si elles sont
# dévoilées ou non.
#---------------------------------------------------------------------------------
var currentRoom
var textureList = [preload("res://Images//Minimap_-3.png"),preload("res://Images//Minimap_-2.png"),preload("res://Images//Minimap_-1.png"),preload("res://Images//Minimap_0.png"),preload("res://Images//Minimap_1.png")]
var textureListS = [preload("res://Images//Minimap_-3_S.png"),preload("res://Images//Minimap_-2_S.png"),preload("res://Images//Minimap_-1_S.png"),preload("res://Images//Minimap_0_S.png"),preload("res://Images//Minimap_1_S.png")]
var textureListH = [preload("res://Images//Minimap_-3_H.png"),preload("res://Images//Minimap_-2_H.png"),preload("res://Images//Minimap_-1_H.png"),preload("res://Images//Minimap_0_H.png"),preload("res://Images//Minimap_1_H.png")]
var textureHidden = preload("res://Images//Minimap_Hidden.png")
var textureHiddenS = preload("res://Images//Minimap_Hidden_S.png")
var textureHiddenH = preload("res://Images//Minimap_Hidden_H.png")
var tile
var link
var pin
var rL
var rList
var lList
var space

var returnButton

signal room_chosen

func _ready() -> void:
	currentRoom = Vector2(0,0)
	tile = $RoomTile
	link = $LinkTile
	pin = $LocPin
	rL = $RoomList
	rList = rL.roomList
	lList = rL.linkList
	space = tile.scale.x * 25
	returnButton = $Return
	returnButton.pressed.connect(OnRoomClick.bind(-1))
	
	# Instantiation des boutons texturés pour les salles (désactivés en général).
	for i in range(lList.size()):
		var dulp_link = link.duplicate()
		dulp_link.position = dulp_link.position - ((lList[i][0]+lList[i][1]) * 0.5 * space)
		add_child(dulp_link)
	tile.texture_disabled = textureList[1]
	tile.texture_normal = textureListS[1]
	
	# Instantiation des connections entre les salles.
	for i in range(rL.roomNumber):
		var dupl_room = tile.duplicate()
		dupl_room.position = dupl_room.position - (rList[i].coordinates * space)
		dupl_room.name = str(i)
		dupl_room.pressed.connect(OnRoomClick.bind(i))
		add_child(dupl_room)
		changeTexture(i)
	
	pin.position = pin.position - (currentRoom * space) # Position du pin de positon (qui indique la salle actuelle).
	tile.hide() # Cacher la case originelle.
	link.hide() # Cacher le lien originel.

# Mettre à jour la texture d'un bouton.
func changeTexture(i : int):
	var r = get_node(str(i))
	if rList[i].isRevealed == false:
		r.texture_disabled = textureHidden
		r.texture_normal = textureHiddenS
		r.texture_hover = textureHiddenH
	else:
		r.texture_disabled = textureList[rList[i].typeRoom+3]
		r.texture_normal = textureListS[rList[i].typeRoom+3]
		r.texture_hover = textureListH[rList[i].typeRoom+3]

# Renvoie la salle choisie lors d'un objet (voir Inventaire.gd).
func OnRoomClick(id : int):
	emit_signal("room_chosen",id)
