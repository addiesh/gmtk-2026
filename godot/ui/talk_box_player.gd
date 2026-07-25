extends PanelContainer

func _ready() -> void:
	self.hide()


func _on_dialogue_area_entered(area: Area2D) -> void:
	print("dialogueareaentered")
	self.show()
	#invoke ancient godot on accessing data on intruding bodies
	#The self-destructing queue-free of the other node might be an issue


func _on_dialogue_area_exited(area: Area2D) -> void:
	print("dialogueareaexited")
	self.hide()
