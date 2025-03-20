extends Node

var roomPreload = preload("res://Classes/Room.tscn")
var roomNumber = 60
var roomList
var linkList
var xLimit = 7
var yLimit = 6
var rTypeList = [75]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roomList = []
	linkList = []
	create_new_room(Vector2(0,0),-1)
	for i in range(1, roomNumber):
		var rType = randi() % 100
		var type = 0
		for t in rTypeList:
			if rType >= t:
				type = type + 1
		place_room(i,type)
	for i in range(5):
		roomList[roomNumber-i-2].typeRoom = -3
	roomList[roomNumber-1].typeRoom = -2
	add_links(roomNumber*0.2)
	
func create_new_room(c : Vector2, type : int):
	var new_room = roomPreload.instantiate()
	new_room.setup(c, type)
	roomList.append(new_room)

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
	#print(old_c)
	linkList.append([old_c,new_c])
	#print(old_c," ",new_c," ",r_dec," ",roomList[linkedRoom].links)

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
			var dec = Vector2(int(cos(r_dec*PI/2)),int(sin(r_dec*PI/2)))
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
