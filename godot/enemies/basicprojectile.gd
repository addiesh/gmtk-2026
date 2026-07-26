extends Node2D

@onready var mespritey = $AnimatedSprite2D
@onready var timer = $DieTimer
@onready var collisionShape = $FireballArea/FireballCollide
var flyorigin: Vector2
var flyto: Vector2
var flyDirection: float
var flyLine: Vector2
@export var speed: int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flyorigin = self.global_position
	flyDirection = flyorigin.angle_to(flyto)
	self.rotation_degrees = flyDirection
	flyLine = (flyto-flyorigin).normalized()
	mespritey.play("Default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.global_position= self.global_position + flyLine * speed


func _on_die_timer_timeout() -> void:
	self.queue_free()

func _on_fireball_area_area_entered(area: Area2D) -> void:
	mespritey.play("impact")
	call_deferred("disableTS")

func disableTS():
	collisionShape.disabled = true
	timer.start(.3)
	await get_tree().create_timer(.5)
	queue_free()
