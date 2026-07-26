extends PanelContainer

var dialogueDataRead
@onready var chudTextDaughter = $HBoxContainer/RichTextLabel
@onready var chudImageDaughter = $HBoxContainer/CenterContainer/Portrait

func _ready() -> void:
	self.hide()


func _on_dialogue_area_entered(area: Area2D) -> void:
	dialogueDataRead = area.get_parent()
	#just take the data from the dialogue data node
	chudTextDaughter.text = dialogueDataRead.Dialogue_text
	chudImageDaughter.texture = dialogueDataRead.Dialogue_image
	
	self.show()

func _on_dialogue_area_exited(_area: Area2D) -> void:
	self.hide()
	#one-time dialogue box. literally just delete it.
	if dialogueDataRead.oneTime:
		dialogueDataRead.queue_free()
