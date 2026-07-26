class_name Ghost
extends Sprite2D

@export var fade_curve: Curve;
@export var ghost_velocity: Vector2 = Vector2.ZERO;
@export_range(0.0, 2.0) var fade_time: float = 1.0;
@onready var spawn_time: float = randf_range(0.0, 123456.0);

@onready var timer: SceneTreeTimer = get_tree().create_timer(
	fade_time, true,
	false,
	true
);

func sgv(v2: Vector2) -> void:
	self.ghost_velocity = v2;

static func make_ghost(gt: Transform2D, tex: Texture2D) -> Ghost:
	var ghost: Ghost = Ghost.new();
	ghost.fade_curve = load("res://particles/ghost_curve.tres");
	ghost.fade_time = 0.5;
	ghost.texture = tex;
	var sm = ShaderMaterial.new();
	sm.copy_from_resource(load("res://particles/ghost_distortion_mat.tres"))
	ghost.material = sm;
	ghost.global_transform = gt;
	ghost.global_scale.x *= 1.5;
	ghost.global_scale.y *= 1.5;
	return ghost;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_timeout);
	pass # Replace with function body.


func _process(delta: float) -> void:
	var fade_offset = clampf((fade_time - timer.time_left) / fade_time, 0.0, 1.0);
	self.modulate.a = fade_curve.sample_baked(fade_offset);
	self.global_position += ghost_velocity * delta;
	(self.material as ShaderMaterial).set_shader_parameter(
		"real_time",
		Timekeeper.get_engine_time()
	);
	pass

func _timeout() -> void:
	self.queue_free();
	pass
