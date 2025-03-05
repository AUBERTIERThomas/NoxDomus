extends OmniLight3D

var roomList
var currentRoom
var lightState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var t = get_node("/root/Node3D/MainUI/Minimap/RoomList")
	while roomList == null:
		await get_tree().create_timer(0.1).timeout
		roomList = t.roomList
	currentRoom = roomList[0]
	lightState = currentRoom.lightState
	print("état de la lumière : "+str(lightState))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match lightState:
		0: # Allumée
			self.omni_range = 30
		1: # Vascillante
			var switchState = randi() % 100 # A chaque frame on tire un nombre aléatoire pour changer d'état
			if self.omni_range == 0: # Eteinte
				if switchState > 94:
					self.omni_range = 30
			else: # Allumée
				if switchState > 96:
					self.omni_range = 0
		2: # Eteinte
			self.omni_range = 0



func _on_main_ui_change_room(id : int) -> void:
	currentRoom = roomList[id]
	lightState = currentRoom.lightState
	print("état de la lumière : "+str(lightState))
	pass # Replace with function body.
