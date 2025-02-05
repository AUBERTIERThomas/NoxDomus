extends Camera3D

var rot_speed = 0.02
var mov_speed = 10
var acceleration = 25.0

var velocity = Vector3.ZERO
var lookAngles = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	lookAngles.y = clamp(lookAngles.y, -PI/2, PI/2)
	set_rotation(Vector3(lookAngles.x, lookAngles.y, 0))
	var direction = updateDirection()
	if Input.is_action_pressed("ui_page_up"):
		self.rotate_y(rot_speed)
	if Input.is_action_pressed("ui_page_down"):
		self.rotate_y(-rot_speed)
	if direction.length_squared() > 0:
		velocity += direction * acceleration * delta
	if velocity.length() > mov_speed:
		velocity = velocity.normalized() * mov_speed
	translate(velocity * delta)

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
