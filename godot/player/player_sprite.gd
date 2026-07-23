extends AnimatedSprite2D

@export var time_gradient: Gradient;
@export var squash_stretch: Curve;

var squash_start_time
var squash_fuel = Vector2.ZERO;

# FIXME: make the initial "bump" from a step curved.s
func _process(delta: float) -> void:
	#$VibeyOutline.flip_h = self.flip_h;
	#$VibeyOutline.self_modulate = 
	#var amp = max(self.scale.distance_squared_to(Vector2.ONE), 0.1);
	self.scale = self.scale.move_toward(Vector2.ONE, delta);

func _on_player_squash_and_stretch() -> void:
	pass

func _frame_ghost() -> Ghost:
	var ghost = Ghost.make_ghost(
		self.global_transform,
		self.sprite_frames.get_frame_texture(
			self.animation,
			self.frame
		)
	);
	get_tree().root.add_child.call_deferred(ghost);
	return ghost;
	
var frame_mod = 0;

func _on_frame_changed() -> void:
	var ghost = self._frame_ghost();
	ghost.self_modulate = Color(Color.AQUA, 0.2);
	if frame_mod > 0 && frame_mod % 2 == 0:
		self.scale = Vector2(1.05, 0.9);
		pass
	frame_mod += 1;
	pass


func _on_animation_changed() -> void:
	frame_mod = 0;
	var ghost = self._frame_ghost();
	ghost.self_modulate = Color(Color.AQUA, 0.2);
	self.scale = Vector2(1.05, 0.9);
	pass
