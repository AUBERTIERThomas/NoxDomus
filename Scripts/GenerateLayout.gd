extends Node
#---------------------------------------------------------------------------------
# Crée l'agencement du manoir.
# Place les salles et leur connections.
#---------------------------------------------------------------------------------
var roomPreload = preload("res://Classes/Room.tscn") # C'est la "classe" salle qu'on va pouvoir instancier.
var roomNumber = 60 # Avec les paramètres actuels, il vaut mieux mettre un nombre important de salle.
var roomList # Stocke toutes les instances de salles. Sera souvent utilisé par les autres scripts.
var linkList # Stocke toutes les connections entre les salles.
var xLimit = 7 # Limite horizontale du manoir (génération).
var yLimit = 6 # Limite verticale du manoir (génération).
var curseMinDist = 8 # Distance minimale entre la salle maudite et l'entrée (peut être bypass si il n'y a pas assez de salles).
var rTypeList = [75] # Définit la proportion pour chaque type de salle classiques (on en a que 2 pour l'instant).

func _ready() -> void:
	roomList = []
	linkList = []
	create_new_room(Vector2(0,0),-1) # Entrée du manoir
	
	# Instantiation et placement des salles.
	for i in range(1, roomNumber):
		var rType = randi() % 100
		var type = 0
		for t in rTypeList:
			if rType >= t:
				type = type + 1
		place_room(i,type)
		
	# Placement des salles à clef et maudite en fin de liste (celles qui sont en moyenne dans les impasses et loin de l'entrée).
	var isCursePlaced = false
	for i in range(5):
		var c = roomList[roomNumber-i-1].coordinates
		if (c.x + c.y >= curseMinDist) and isCursePlaced == false :
			roomList[roomNumber-i-1].typeRoom = -2
			isCursePlaced = true
		else :
			roomList[roomNumber-i-1].typeRoom = -3
	if isCursePlaced == false :
		roomList[roomNumber-6].typeRoom = -2
	else :
		roomList[roomNumber-6].typeRoom = -3
	
	# Ajout de quelques connections en plus pour la fluidité.
	add_links(roomNumber*0.2)

# Instancie une salle (voir Room.gd).
func create_new_room(c : Vector2, type : int):
	var new_room = roomPreload.instantiate()
	new_room.setup(c, type)
	roomList.append(new_room)

# Place la salle sur un emplacement adjacent à une autre, et s'y connecte.
func place_room(i : int, type : int):
	var have_found = false
	var old_c
	var new_c
	var linkedRoom
	var r_dec
	while !have_found:
		have_found = true
		linkedRoom = randi() % (i)
		r_dec = randi() % 4
		var dec = Vector2(int(cos(r_dec*PI/2)),int(sin(r_dec*PI/2)))
		new_c = roomList[linkedRoom].coordinates + dec
		# On vérifie que la salle ne dépasse pas de la zone allouée au manoir. Attention : peut boucler indéfiniment si aucun emplacement ne reste.
		if (new_c.x < -xLimit) or (new_c.x > xLimit) or (new_c.y < 0) or (new_c.y > yLimit):
			have_found = false
		else :
			for c in roomList:
				if (c.coordinates == new_c):
					have_found = false
	
	old_c = roomList[linkedRoom].coordinates
	roomList[linkedRoom].links[(r_dec+2)%4] = true
	create_new_room(new_c,type)
	roomList[roomList.size()-1].links[r_dec] = true
	linkList.append([old_c,new_c])
	#print(old_c," ",new_c," ",r_dec," ",roomList[linkedRoom].links)

# Ajout de quelques connections en plus pour la fluidité.
func add_links(nb : int):
	for i in range(nb):
		var have_found = false
		var linkedRoom
		var r_dec
		var c_temp
		var new_link
		while !have_found:
			linkedRoom = randi() % (roomNumber)
			r_dec = randi() % 4
			var dec = Vector2(int(cos(r_dec*PI/2)),int(sin(r_dec*PI/2))) # Technique de pro pour éviter de faire des cas.
			var old_c = roomList[linkedRoom].coordinates
			var new_c = roomList[linkedRoom].coordinates + dec
			new_link = [old_c,new_c]
			for c in roomList:
				if (c.coordinates == new_c):
					have_found = true
					c_temp = c
			for l in linkList:
				if (l == new_link):
					have_found = false
		roomList[linkedRoom].links[(r_dec+2)%4] = true
		c_temp.links[r_dec] = true
		linkList.append(new_link)
