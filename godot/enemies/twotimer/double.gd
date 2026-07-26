class_name BigDouble
extends BigGarg

@onready var fireTime = $Timer
@onready var fireBall = load("res://enemies/fireball.tscn")
@onready var speedPerm = speed

@export var ballSpeed: int
@export var fireSpeed: int

func _physics_process(delta: float) -> void:
	super(delta);
	if ai_target_track != null && ai_target_track.global_position.distance_to(self.global_position) < sightRange && (playerRay.get_collider() == ai_target_track):
		if fireTime.is_stopped():
			fireFireball((playerRay.target_position));
			fireTime.start(fireSpeed)

func fireFireball(direction: Vector2):
	isFiring = true
	await get_tree().create_timer(1)
	speed = speedPerm
	var instanceBall = fireBall.instantiate()
	owner.add_child(instanceBall)
	instanceBall.speed = ballSpeed
	instanceBall.transform = self.transform
	instanceBall.flyto = playerRay.target_position
	isFiring = false
