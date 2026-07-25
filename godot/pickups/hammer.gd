extends Pickup

@onready var sprite: Sprite2D = $Sprite;

func _equip() -> void:
	self.is_held = true;
	self.freeze = true;
	self.linear_velocity = Vector2.ZERO;
	self.angular_velocity = 0.0;

func _throw(direction: Vector2) -> void:
	self.is_held = false;
	self.freeze = false;
	self.linear_velocity = direction * 2048.0;
	var angv;
	if direction.x > 0.0:
		sprite.flip_v = false;
		angv = 64.0;
	else:
		sprite.flip_v = true;
		angv = -64.0
		pass
	self.angular_velocity = angv;

func _process(_delta: float) -> void:
	if is_held:
		var ang = wrap(self.rotation_degrees, 0, 360);
		if ang > 90 && ang < 270:
			sprite.flip_v = true;
		else:
			sprite.flip_v = false;
			
	
	if self.linear_velocity.length_squared() > 4.0 || is_held:
		var ghost = Ghost.make_ghost(self.global_transform, self.sprite.texture);
		ghost.self_modulate = Color(3.294, 2.236, 0.0, 0.05);
		ghost.flip_v = self.sprite.flip_v;
		if is_held:
			ghost.fade_time = 0.1;
			pass
		get_tree().root.add_child(ghost);
		pass
	
func _physics_process(delta: float) -> void:
	var hit: KinematicCollision2D = move_and_collide(self.linear_velocity, true);
	if hit == null:
		return;
	var obj: Object = hit.get_collider();
	if obj != null && obj.has_method("hurt"):
		obj.call("hurt");
		
