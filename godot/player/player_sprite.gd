extends Sprite2D

@export var dilation_gradient: Gradient;

func _ready() -> void:
	$VibeyOutline.play("default");

func _process(_delta: float) -> void:
	$VibeyOutline.flip_h = self.flip_h;
	$VibeyOutline.self_modulate = dilation_gradient.sample(Timekeeper.timescale());
