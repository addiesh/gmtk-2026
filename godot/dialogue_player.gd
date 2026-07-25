extends Node2D

#what to say
@export var Dialogue_text: String
#who to show
@export var Dialogue_image: int

@export var oneTime: bool

func _on_dialoguezone_area_entered(area: Area2D) -> void:
	if oneTime:
		#Ok so like this might cause issues teehee
		queue_free()
