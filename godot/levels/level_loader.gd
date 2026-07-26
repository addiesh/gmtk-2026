class_name LevelLoader
extends Node

@export var taper_fade: NinjaTaperFade;

var scene_to_load: PackedScene = null;
var is_reloading_scene = false;

func _ready() -> void:
	taper_fade.midpoint.connect(_nuke_the_building);
	taper_fade.endpoint.connect(_on_reload_finished);

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart_level"):
		if !is_reloading_scene:
			print("i LOVE fun");
			_scene_reload();
		else:
			print("i hate fun");
		pass
		
func _nuke_the_building() -> void:
	for node in self.get_children():
		node.queue_free();
	self.add_child(scene_to_load.instantiate());
	

func _on_reload_finished() -> void:
	is_reloading_scene = false;
	print("reload finished!");

func _scene_reload() -> void:
	if is_reloading_scene || scene_to_load == null:
		print("ignored reload request");
		return;
	is_reloading_scene = true;
	print("called taper fade");
	taper_fade.fade_inout();
