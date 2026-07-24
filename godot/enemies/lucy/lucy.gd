class_name Enemy
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite;
var last_hit_time = -INF;
@onready var squash: Curve = preload("res://hurt_squash.tres");

func _on_hit(body: Area2D) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0;
	#if last_hit_time + 1.0 <
	self.last_hit_time = Time.get_ticks_msec() / 1000.0;
	var phys = body.get_parent();
	if phys is RigidBody2D:
		phys.linear_velocity = -phys.linear_velocity.normalized() * 512.0;
		phys.angular_velocity /= 2.0;
		pass
	elif phys is CharacterBody2D:
		phys.velocity = -phys.velocity.normalized() * 512.0;
		pass
	pass

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0;
	var sample = clampf((current_time - last_hit_time) / 0.2, 0.0, 1.0);
	var sampled = squash.sample_baked(sample)
	sprite.scale.y = sampled;
	sprite.self_modulate = Color.WHITE.lerp(Color.RED, sampled);
