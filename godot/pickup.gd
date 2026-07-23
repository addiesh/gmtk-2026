class_name Pickup
extends PickupBase

@export var sprite: Resource


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.overworld_sprite = load("res://icon.svg");
	pass # Replace with function body.

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
