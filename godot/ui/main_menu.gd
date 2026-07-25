extends Control

var fadeout: SceneTreeTimer = null;
@onready var ninja_taper_fade: ColorRect = $ColorRect;
const FADE_DURATION: float = 3.0;

func _on_button_pressed() -> void:
	fadeout = get_tree().create_timer(
		FADE_DURATION,
		true,
		false,
		true
	);
	

func _process(_delta: float) -> void:
	if fadeout == null:
		return;
	self.modulate = self.modulate.darkened(
		(FADE_DURATION - fadeout.time_left) / FADE_DURATION / 2.0
	);
	var skibidi = clamp((FADE_DURATION - (fadeout.time_left)) / (FADE_DURATION / 1.0), 0.0, 1.0);
	ninja_taper_fade.color.a = skibidi;
