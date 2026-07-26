extends Enemy

var is_laughing = false;

func _cackle_end() -> void:
	is_laughing = false;
	get_tree().create_timer(
		10.0,
		true,
		false,
		false
	).timeout.connect(_cackle);
	
func _cackle() -> void:
	is_laughing = true;
	$Laugh.play();
	get_tree().create_timer(
		1.0,
		true,
		false,
		true
	).timeout.connect(_cackle_end);
	
func _on_hurt() -> void:
	if !$Yelp.playing:
		$Yelp.play();

func _ready() -> void:
	_cackle();
	
func _jiggle() -> void:
	if is_laughing:
		self.last_squash_time = Timekeeper.get_engine_time();
	pass

func _process(delta: float) -> void:
	super(delta);
	sprite.speed_scale = 1.0;
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
	
	elif is_laughing:
		sprite.speed_scale = 1.0 / Timekeeper.timescale();
		sprite.animation = "laugh";
	elif self.velocity.length_squared() < 8.0:
		sprite.animation = "default";
	else:
		if self.velocity.y > 0.1:
			sprite.animation = "default";
		elif self.velocity.y < -0.1:
			sprite.animation = "back";
		pass
		# horiz
		if self.velocity.x > 0.1:
			sprite.flip_h = true;
		elif self.velocity.x < -0.1:
			sprite.flip_h = false;
	pass
	
	if !sprite.is_playing():
		sprite.play();
	
	var current_time = Timekeeper.get_engine_time();
	var sample_hurt = clampf(
		(current_time - last_hit_time) / INVULN_TIME,
		0.0,
		1.0
	);
	var sample_generic = clampf(
		(current_time - last_squash_time) / 0.2,
		0.0,
		1.0
	);
	var sampled = squash.sample_baked(min(sample_hurt, sample_generic));
	sprite.scale.y = sampled;
	sprite.self_modulate = (Color.RED * 2.0).lerp(Color.WHITE, sample_hurt);

func _physics_process(delta: float) -> void:
	if _is_on_cooldown() || _is_on_melee_cooldown() || is_laughing:
		velocity = velocity.move_toward(Vector2.ZERO, delta  * KNOCKBACK_STRENGTH * 2.0 / INVULN_TIME);
	elif ai_target_track != null && ai_target_track.global_position.distance_to(self.global_position) < 1024.0:
		var game_time = Timekeeper.get_time();
		var target_vel = (
			ai_target_track.global_position - global_position
		).normalized().lerp(Vector2(
			cos(game_time),
			sin(game_time)
		), 0.5)
		
		velocity = velocity.move_toward(target_vel * speed, delta * acceleration);
		pass
	self.move_and_slide();
