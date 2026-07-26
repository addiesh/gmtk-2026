extends "res://enemies/garg/BigGarg/big_garg.gd"
class_name BigDouble

@onready var fireTime = $Timer
@export var fireBall = load("res://enemies/fireball.tscn")

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
	sprite.animation = ""
	await get_tree().create_timer(1)
	var instanceBall = fireBall.instantiate()
	owner.add_child(instanceBall)
	instanceBall.speed = ballSpeed
	print(instanceBall.position.x)
	instanceBall.transform = self.transform
	instanceBall.flyto = playerRay.target_position
	isFiring = false
