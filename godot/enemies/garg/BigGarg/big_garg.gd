extends Enemy

func _process(_delta: float) -> void:
	super(_delta);
	if _is_on_cooldown():
		sprite.animation = "hurt";
		if self.velocity.x > 0.1:
			sprite.flip_h = false
		if self.velocity.x < -0.1:
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
	

#monitor surroundings with area 2D
#if player enters collision shape, raycast to see if player is seen first.
#if player seen first in ray, follow. Copy player coords and lerp towards
#if player not seen in x seconds, quit.

func _on_sight_area_entered(area: Area2D) -> void:
	
	pass # Replace with function body.
