extends OmniLight3D
#---------------------------------------------------------------------------------
# Gère la lumière de la pièce.
#---------------------------------------------------------------------------------
var roomList
var currentRoom
var lightState

func _ready() -> void:
	var t = get_node("/root/Node3D/MainUI/Minimap/RoomList") # Obtient la liste des salles du manoir.
	while roomList == null: # Ce script est appelé très tôt (à cause de son nom ?) donc on doit attendre que cette dite liste soit générée.
		await get_tree().create_timer(0.1).timeout
		roomList = t.roomList
	currentRoom = roomList[0]
	lightState = currentRoom.lightState # Récupère l'état de la lumière associée à la salle (voir Room.gd).
	print("état de la lumière : "+str(lightState))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match lightState: # Comportement des types de lumières
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

# On update la lumière au changement de salle
func _on_main_ui_change_room(id : int) -> void:
	currentRoom = roomList[id]
	lightState = currentRoom.lightState
	print("état de la lumière : "+str(lightState))
	pass # Replace with function body.
