extends Enemy

@onready var playerRay = $PlayerSeeker
var sightRange = 1024

@onready var playerInitPos = ai_target_track.global_position

var space_state
var query
var result
@onready var FUCKASSHAMMER = get_tree().get_first_node_in_group("HAMMER")

func _ready():
	playerRay.add_exception(get_tree().get_first_node_in_group("HAMMER"))



func _process(_delta: float) -> void:
	super(_delta);
	if _is_on_cooldown():
		sprite.animation = "hurt";
		if self.velocity.x > 0.1:
			sprite.flip_h = false
		if self.velocity.x < -0.1:
			sprite.flip_h = true;
	elif _is_on_melee_cooldown():
		sprite.animation = "attack";
		if self.velocity.x > 0.1:
			sprite.flip_h = false;
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
	
	var current_time = Timekeeper.get_engine_time();
	var sample_hurt = clampf(
		(current_time - last_hit_time) / INVULN_TIME,
		0.0,
		1.0
	);
	var sample_generic = clampf(
		(current_time - last_squash_time) / MELEE_COOLDOWN_TIME,
		0.0,
		1.0
	);
	var sampled = squash.sample_baked(min(sample_hurt, sample_generic));
	sprite.scale.y = sampled;
	sprite.self_modulate = (Color.RED * 2.0).lerp(Color.WHITE, sample_hurt);

	
	if !sprite.is_playing():
		sprite.play();
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		self.velocity = -velocity.normalized() * 2048.0;
		body.velocity = -velocity.normalized() * 1024.0;
		self.last_squash_time = Timekeeper.get_engine_time();
		if !body.is_dashing():
			body
			body.hurt();
			self.melee_cooldown_time = Timekeeper.get_time();
	pass

func _physics_process(delta: float) -> void:
	
	
	#locking garg's raycast onto the player
	playerRay.target_position.x = playerInitPos.x - self.global_position.x + (-playerInitPos.x + ai_target_track.global_position.x)
	playerRay.target_position.y = playerInitPos.y - self.global_position.y + (-playerInitPos.y + ai_target_track.global_position.y)

	
	if _is_on_cooldown() || _is_on_melee_cooldown() || (playerRay.get_collider() != ai_target_track):
		velocity = velocity.move_toward(Vector2.ZERO, delta  * KNOCKBACK_STRENGTH * 2.0 / INVULN_TIME);
		
	
	elif ai_target_track != null && ai_target_track.global_position.distance_to(self.global_position) < sightRange && (playerRay.get_collider() == ai_target_track):
		var target_vel = (ai_target_track.global_position - global_position).normalized() * speed;
		velocity = velocity.move_toward(target_vel, delta * acceleration);
		
	self.move_and_slide();
	pass
