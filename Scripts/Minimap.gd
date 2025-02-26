extends Control

var currentRoom
var textureList = [preload("res://Images//Minimap_-3.png"),preload("res://Images//Minimap_-2.png"),preload("res://Images//Minimap_-1.png"),preload("res://Images//Minimap_0.png"),preload("res://Images//Minimap_1.png")]
var textureHidden = preload("res://Images//Minimap_Hidden.png")
var tile
var link
var pin
var rL
var rList
var lList
var space

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentRoom = Vector2(0,0)
	tile = $RoomTile
	link = $LinkTile
	pin = $LocPin
	rL = $RoomList
	rList = rL.roomList
	lList = rL.linkList
	space = tile.scale.x * 25
	
	for i in range(lList.size()):
		var dulp_link = link.duplicate()
		dulp_link.position = dulp_link.position - ((lList[i][0]+lList[i][1]) * 0.5 * space)
		add_child(dulp_link)
	tile.texture = textureList[1]
	for i in range(rL.roomNumber):
		var dupl_room = tile.duplicate()
		dupl_room.position = dupl_room.position - (rList[i].coordinates * space)
		dupl_room.name = str(i)
		add_child(dupl_room)
		changeTexture(i)
	pin.position = pin.position - (currentRoom * space)
	tile.hide()
	link.hide()
	pass # Replace with function body.

func changeTexture(i : int):
	var r = get_node(str(i))
	if rList[i].isRevealed == false:
		r.texture = textureHidden
	else:
		r.texture = textureList[rList[i].typeRoom+3]
