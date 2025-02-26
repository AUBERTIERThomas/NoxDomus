extends OmniLight3D

var lightState = 0
var lightStateList = [60,85]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ls = randi() % 100
	for i in range(lightStateList.size()):
		if ls >= lightStateList[i]:
			lightState += 1
	print("état de la lumière : "+str(lightState))
	match lightState:
		0: # Allumée
			self.omni_range = 30
		2: # Eteinte
			self.omni_range = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match lightState:
		1: # Vascillante
			var switchState = randi() % 100 # A chaque frame on tire un nombre aléatoire pour changer d'état
			if self.omni_range == 0: # Eteinte
				if switchState > 94:
					self.omni_range = 30
			else: # Allumée
				if switchState > 96:
					self.omni_range = 0
