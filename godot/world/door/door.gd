class_name SpookyDoor
extends Area2D

@export var door_scene: PackedScene;
var kill = false;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !kill:
		kill = true;
		var loader: LevelLoader = get_tree().root.get_node("Main/LevelLoader");
		loader.scene_to_load = door_scene;
		loader._scene_reload();
		$Sprite.play("default");
	pass
	
func _process(delta: float) -> void:
	($Sprite).speed_scale = 1.0 / Timekeeper.timescale();
	($Sprite2D.material as ShaderMaterial).set_shader_parameter(
		"real_time",
		Timekeeper.get_engine_time(),
	);
	
