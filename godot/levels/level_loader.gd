class_name LevelLoader
extends Node

var scene_to_load: PackedScene = null;
var reload_taper_fade: SceneTreeTimer;
var is_reloading_scene = false;

func _scene_reload() -> void:
	if is_reloading_scene || scene_to_load == null:
		return;
	is_reloading_scene = true;
	reload_taper_fade = get_tree().create_timer(
		0.5,
		true,
		false,
		true
	);
	for node in self.get_children():
		node.queue_free();
	self.add_child(scene_to_load.instantiate());
	
