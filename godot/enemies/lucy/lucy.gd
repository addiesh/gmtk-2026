extends Enemy

func _process(delta: float) -> void:
	super(delta);
	if _is_on_cooldown():
		if self.velocity.y > 0.1:
			sprite.animation = "hurt-b";
		else:
			sprite.animation = "hurt-f";
			pass
		
		if self.velocity.x > 0.1:
			sprite.flip_h = false
		elif self.velocity.x < -0.1:
			sprite.flip_h = true;
		
	elif self.velocity.length_squared() < 8.0:
		sprite.animation = "default";
	elif self.velocity.x > 0.1:
		sprite.animation = "walk";
		sprite.flip_h = true;
	elif self.velocity.x < -0.1:
		sprite.animation = "walk";
		sprite.flip_h = false;
	pass
	
	if !sprite.is_playing():
		sprite.play();
	

func _physics_process(delta: float) -> void:
	super(delta);
