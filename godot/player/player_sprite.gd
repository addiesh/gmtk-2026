extends Sprite2D

func _ready() -> void:
	$VibeyOutline.play("default");

func _process(_delta: float) -> void:
	$VibeyOutline.flip_h = self.flip_h;
