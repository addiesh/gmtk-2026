class_name NinjaTaperFade
extends CanvasLayer

signal midpoint;

const FADE_DURATION: float = 1.0;

var fade_in = false;
@onready var three_dots: ColorRect = $ColorRect;
@onready var fadeout: SceneTreeTimer = null;

func fade_inout():
	if fade_in || fadeout != null:
		return;
	fade_in = false;
	fadeout = self.get_tree().create_timer(
		FADE_DURATION,
		true,
		false,
		true
	);
	fadeout.timeout.connect(_on_timeout);

func _on_timeout():
	if !fade_in:
		fade_in = true;
		midpoint.emit();
	fadeout = self.get_tree().create_timer(
		FADE_DURATION,
		true,
		false,
		true
	);
	pass

func _process(_delta: float) -> void:
	if fadeout == null:
		return;
	var ft = (FADE_DURATION - (fadeout.time_left)) / FADE_DURATION;
	var skibidi = clamp(ft, 0.0, 1.0);
	if fade_in:
		three_dots.color.a = 1.0 - skibidi;
	else:
		three_dots.color.a = skibidi;
	pass
