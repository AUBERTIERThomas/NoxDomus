extends Camera3D
#---------------------------------------------------------------------------------
# Gère le déplacement du joueur dans la salle en 3D.
#---------------------------------------------------------------------------------
var rot_speed = 0.04
var mov_speed = 13
var acceleration = 25.0
var dim_salle = 14

var velocity = Vector3.ZERO
var lookAngles_y = 0

func _process(delta):
	if Input.is_action_pressed("ui_page_up"):
		lookAngles_y += rot_speed
	if Input.is_action_pressed("ui_page_down"):
		lookAngles_y -= rot_speed
	#lookAngles_y = clamp(lookAngles_y, -PI, PI) # Si on veut limiter l'angle de rotation de la caméra (déconseillé).
	set_rotation(Vector3(0, lookAngles_y, 0))
	var direction = updateDirection()
	if direction.length_squared() > 0:
		velocity += direction * acceleration * delta
	if velocity.length() > mov_speed:
		velocity = velocity.normalized() * mov_speed
	translate(velocity * delta)
	position.x = clamp(position.x, -dim_salle, dim_salle)
	position.z = clamp(position.z, -dim_salle, dim_salle)

func updateDirection() :
	var dir = Vector3()
	if Input.is_action_pressed("ui_left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("ui_right"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("ui_up"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("ui_down"):
		dir += Vector3.BACK
	if dir == Vector3.ZERO:
		velocity = Vector3.ZERO
	return dir.normalized()
