extends Pickup

@onready var sprite: Sprite2D = $Sprite;

func _throw(direction: Vector2) -> void:
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

func _process(delta: float) -> void:
	if self.linear_velocity.length_squared() > 4.0:
		var ghost = Ghost.make_ghost(self.global_transform, self.sprite.texture);
		ghost.self_modulate = Color(3.294, 2.236, 0.0, 0.05);
		ghost.flip_v = self.sprite.flip_v;
		self.add_sibling(ghost);
		pass
	
