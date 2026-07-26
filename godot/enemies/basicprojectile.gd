extends RigidBody2D

@onready var mespritey = $AnimatedSprite2D
@onready var timer = $DieTimer
var flyDirection: Vector2
var velocity: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mespritey.play("Default")
	mespritey.rotation = flyDirection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position+= flyDirection * velocity

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	mespritey.play("impact")
	self.process = false
	self.FireballCollide.disable()
	timer.start(.3)

func _on_die_timer_timeout() -> void:
	self.queue_free()
