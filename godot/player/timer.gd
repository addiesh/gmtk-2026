class_name CrabTimerManager
extends PanelContainer

const TIME_DURATION: float = 60.0;

var clock_start_time: float = 0.0;
var time_spent: float = 0.0;
var is_ticking: bool = false;

@export var player: Player;
@onready var time_text = $CenterContainer/VBoxContainer/TimeRef;

var poggers: Vector2 = Vector2.ZERO

func _start_clock() -> void:
	time_spent = 0.0;
	clock_start_time = Timekeeper.get_time();
	is_ticking = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _remaining_time() -> float:
	return TIME_DURATION - (Timekeeper.get_time() - clock_start_time) - time_spent;

func remove_time(dec_by: float):
	time_spent += dec_by;
	self_modulate = self_modulate * 4.0;

func _on_jitter() -> void:
	var veldir = player.velocity.normalized();
	self.offset_transform_position += veldir;
	self.offset_transform_position += Vector2.from_angle(randf_range(0.0, TAU));
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart_level") && !is_ticking:
		_start_clock();
		pass
	
	if player.is_dashing(): 
		_on_jitter();
		pass;
	var delta = Timekeeper.real_process_delta();
	self.offset_transform_position *= 1.0 - delta * 4.0;
	self_modulate = self_modulate.lerp(Color.WHITE, delta * 4.0);
	
	time_text.text = "%2.1f" % _remaining_time()
	
	pass
