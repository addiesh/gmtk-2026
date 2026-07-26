extends Node2D

@onready var mespritey = $AnimatedSprite2D
@onready var timer = $DieTimer
var flyorigin: Vector2
var flyto: Vector2
var flyDirection: float
var flyLine: Vector2
@export var speed: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flyDirection = flyorigin.angle_to(flyto)
	flyLine = flyto-flyorigin
	flyorigin = self.global_position
	mespritey.play("Default")
	self.rotation_degrees = flyorigin.angle_to(flyto)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position+= flyLine * speed




func _on_die_timer_timeout() -> void:
	self.queue_free()


func _on_body_entered(body: Node) -> void:
	mespritey.play("impact")
	self.process = false
	self.FireballCollide.disable()
	timer.start(.3)
