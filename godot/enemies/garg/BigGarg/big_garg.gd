extends Enemy

@onready var playerRay = $PlayerSeeker
@export var sightRange: int

@onready var playerInitPos = ai_target_track.global_position

#exlusively to disable before death
@onready var collision1 = $Hitbox/CollisionShape2D
@onready var collision2 = $Area2D/CollisionShape2D

var isFiring: bool = false
var dueToDie: bool = false

func _ready():
	#multiple hammers? loop ts
	#put a hammer out of bounds so ts doesn't crash
	playerRay.add_exception(get_tree().get_first_node_in_group("HAMMER"))

func _on_hurt() -> void:
	$DasConcrete.play();

func _process(_delta: float) -> void:
	super(_delta);
	if isFiring:
		sprite.animation = "attack"
	if dueToDie:
		sprite.animation = "DIE";
	elif _is_on_cooldown():
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


func _on_die() -> void:
	dueToDie = true
	call_deferred("processSETFORENEMIES")
	await get_tree().create_timer(.5).timeout;
	self.call_deferred("queue_free")

func processSETFORENEMIES():
	print("processDIE")
	speed = 0
	velocity = Vector2(0,0)
	collision1.disabled = true
	collision2.disabled = true	
