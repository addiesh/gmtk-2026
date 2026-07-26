class_name CrabTimerManager
extends PanelContainer

@export var time_duration: float = 60.0;

var clock_start_time: float = 0.0;
var time_spent: float = 0.0;
@export var is_ticking: bool = true;

@export var player: Player;
@onready var time_text = $CenterContainer/VBoxContainer/TimeRef;

var poggers: Vector2 = Vector2.ZERO

func _ready() -> void:
	time_spent = 0.0;
	clock_start_time = Timekeeper.get_time();

func _remaining_time() -> float:
	if !is_ticking: return INF;
	return max(
		time_duration - (
			Timekeeper.get_time() - clock_start_time
		) - time_spent,
		0.0
	);

func remove_time(dec_by: float):
	time_spent += dec_by;
	self_modulate = (self_modulate * 4.0).clamp(
		Color.WHITE,
		Color.WHITE * 8.0,
	);

func _on_jitter() -> void:
	var veldir = player.velocity.normalized();
	self.offset_transform_position += veldir;
	self.offset_transform_position += Vector2.from_angle(randf_range(0.0, TAU));
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_text.text = "%2.1f" % _remaining_time();


	if player.is_dashing():
		_on_jitter();
		pass;
	var delta = Timekeeper.real_process_delta();
	self.offset_transform_position *= 1.0 - delta * 4.0;
	self_modulate = self_modulate.lerp(Color.WHITE, delta * 4.0);


	if _remaining_time() == 0:
		Timekeeper.time_flags().is_time_frozen = true;
		return;
	else:
		Timekeeper.time_flags().is_time_frozen = false;

	pass
