class_name BigDouble
extends BigGarg

@onready var fireTime = $Timer
@onready var fireball2 = preload("res://enemies/lucy/gballs.tscn");
@onready var speedPerm = speed

@export var ballSpeed: int
@export var fireSpeed: int

func _physics_process(delta: float) -> void:
	super(delta);
	if ai_target_track != null && ai_target_track.global_position.distance_to(self.global_position) < sightRange && (playerRay.get_collider() == ai_target_track):
		if fireTime.is_stopped():
			fireFireball();
			fireTime.start(fireSpeed)

func fireFireball():
	var sorgy = fireball2.instantiate();
	sorgy.global_position = self.global_position;
	sorgy.viva = (ai_target_track.global_position - self.global_position).normalized() * 200.0;
	get_tree().root.add_child(sorgy);
