class_name TalkBox
extends Control

@export var sprite: Texture2D;

func _update_portrait() -> void:
	($HBoxContainer/CenterContainer/Portrait).texture = sprite;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_portrait();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
