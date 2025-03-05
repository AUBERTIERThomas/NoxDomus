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

var minimap
var roomListNode
var roomList

var currentRoom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	childList = [$Mur1, $Mur2, $Mur3, $Mur4, $Plafond, $Sol]
	minimap = $MainUI/Minimap
	roomListNode = $MainUI/Minimap/RoomList
	roomList = roomListNode.roomList
	room_init(0)

func room_init(id : int) -> void:
	var s = fullTextList.size()
	wall1 = fullTextList[randi() % s]
	wall2 = fullTextList[randi() % s]
	wall3 = fullTextList[randi() % s]
	wall4 = fullTextList[randi() % s]
	textList = [wall1, wall2, wall3, wall4, ceiling, ground]
	for i in range(6):
		apply_texture(i)
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
