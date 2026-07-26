class_name Enemy
extends CharacterBody2D

const INVULN_TIME: float = 0.25;
const MELEE_COOLDOWN_TIME: float = 0.75;
@export var KNOCKBACK_STRENGTH: int = 1024;

@export var acceleration: float = 1000.0;
@export var speed: float = 600.0;
#SET IN CODE FOR SPAWNED ENEMIES
@export var ai_target_track: Player;

@export var enemyHealth: int;
signal die

var last_squash_time = -INF;
var melee_cooldown_time = -INF;
var cooldown_time: float = -INF
@export var sprite: AnimatedSprite2D;
var last_hit_time: float = -INF;
@onready var squash: Curve = preload("res://hurt_squash.tres");

func _is_on_melee_cooldown() -> bool:
	if Timekeeper.get_time() <= melee_cooldown_time + MELEE_COOLDOWN_TIME:
		return true;
	return false;

func _is_on_cooldown() -> bool:
	if Timekeeper.get_time() <= cooldown_time + INVULN_TIME:
		return true;
	return false;

func _on_hurt() -> void:
	pass

func _on_hit(_area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int) -> void:
	var current_real_time = Timekeeper.get_engine_time();
	var current_game_time = Timekeeper.get_time();
	if _is_on_cooldown():
		return;
	var phys = area.get_parent();

	var shape: CollisionShape2D = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index));


	if phys is Pickup:
		hurtTracker()
		if phys.is_held:
			self.cooldown_time = current_game_time;
			self.last_hit_time = current_real_time;
			_on_hurt();
		elif phys.linear_velocity.length() > 200.0:
			self.cooldown_time = current_game_time;
			self.last_hit_time = current_real_time;
			var pvn = phys.linear_velocity.normalized()
			phys.linear_velocity = -pvn * 512.0;
			phys.angular_velocity /= 2.0;
			self.velocity = pvn * KNOCKBACK_STRENGTH;
			_on_hurt();
		pass
	else:
		self.velocity = (self.global_position - shape.global_position).normalized();

	pass

func _process(_delta: float) -> void:
	var current_time = Timekeeper.get_engine_time();
	var sample = clampf((current_time - last_hit_time) / INVULN_TIME, 0.0, 1.0);
	var sampled = squash.sample_baked(sample)
	sprite.scale.y = sampled;
	sprite.self_modulate = (Color.RED * 2.0).lerp(Color.WHITE, sample);

func _physics_process(delta: float) -> void:
	if _is_on_cooldown() || _is_on_melee_cooldown():
		velocity = velocity.move_toward(Vector2.ZERO, delta  * KNOCKBACK_STRENGTH * 2.0 / INVULN_TIME);
	elif ai_target_track != null && ai_target_track.global_position.distance_to(self.global_position) < 1024.0:
		var target_vel = (ai_target_track.global_position - global_position).normalized() * speed;
		velocity = velocity.move_toward(target_vel, delta * acceleration);
		pass
	self.move_and_slide();
	pass

func hurtTracker():
	enemyHealth-= 1
	print(enemyHealth)
	if enemyHealth <= 0:
		die.emit()
