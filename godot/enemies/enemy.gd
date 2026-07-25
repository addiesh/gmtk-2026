class_name Enemy
extends CharacterBody2D

const INVULN_TIME: float = 0.25;
const KNOCKBACK_STRENGTH: float = 1024.0;

@export var acceleration: float = 1000.0;
@export var speed: float = 600.0;

var ai_target_track: Node2D;

var cooldown_time: float = -INF
@export var sprite: AnimatedSprite2D;
var last_hit_time: float = -INF;
@onready var squash: Curve = preload("res://hurt_squash.tres");

func _is_on_cooldown() -> bool:
	if Timekeeper.get_time() <= cooldown_time + INVULN_TIME:
		return true;
	return false;

func _on_hit(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var current_real_time = Timekeeper.get_engine_time();
	var current_game_time = Timekeeper.get_time();
	if _is_on_cooldown():
		return;
	self.cooldown_time = current_game_time;
	self.last_hit_time = current_real_time;
	var phys = area.get_parent();
	
	var shape: CollisionShape2D = area.shape_owner_get_owner(area.shape_find_owner(area_shape_index));
	
	var knockback_dir;
	
	if phys is RigidBody2D:
		var pvn = phys.linear_velocity.normalized()
		phys.linear_velocity = -pvn * 512.0;
		phys.angular_velocity /= 2.0;
		knockback_dir = pvn;
		pass
	elif phys is CharacterBody2D:
		var pvn = phys.velocity.normalized()
		phys.velocity = -pvn * 512.0;
		knockback_dir = pvn;
		pass
	else:
		knockback_dir = (self.global_position - shape.global_position).normalized();
	# knockback
	self.velocity = knockback_dir * KNOCKBACK_STRENGTH;
	pass

func _process(_delta: float) -> void:
	var current_time = Timekeeper.get_engine_time();
	var sample = clampf((current_time - last_hit_time) / INVULN_TIME, 0.0, 1.0);
	var sampled = squash.sample_baked(sample)
	sprite.scale.y = sampled;
	sprite.self_modulate = Color.RED.lerp(Color.WHITE, sample);

func _physics_process(delta: float) -> void:
	if _is_on_cooldown():
		velocity = velocity.move_toward(Vector2.ZERO, delta  * KNOCKBACK_STRENGTH * 2.0 / INVULN_TIME);
	elif ai_target_track != null:
		var target_vel = (global_position - ai_target_track.global_position).normalized() * speed;
		velocity = velocity.move_toward(target_vel, delta * acceleration);
		pass
	self.move_and_slide();
	pass
