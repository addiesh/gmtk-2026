extends Control

var fadeout: SceneTreeTimer = null;
@export var level_loader: LevelLoader;
@export var taper_fade: NinjaTaperFade;
var skibidi = false;
const FADE_DURATION: float = 1.0; 

func _on_button_pressed() -> void:
	if fadeout != null:
		return;
	skibidi = true;
	fadeout = get_tree().create_timer(
		FADE_DURATION,
		true,
		false,
		true
	);
	fadeout.timeout.connect(_reload_and_self_destruct);

func _reload_and_self_destruct():
	level_loader.scene_to_load = preload("res://levels/tutorial.tscn");
	level_loader._scene_reload();
	taper_fade.midpoint.connect(self.queue_free);
	pass

func _process(_delta: float) -> void:
	if fadeout == null:
		return;
	self.modulate = self.modulate.darkened(
		(FADE_DURATION - fadeout.time_left) / FADE_DURATION / 2.0
	);
