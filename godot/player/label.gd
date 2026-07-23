extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.text = "TIMESCALE = %s\nTARGET = %s\ndilated time (S) = %s" % [
		Timekeeper.timescale(),
		Timekeeper.timescale_target(),
		Timekeeper.get_time()
	];
	pass
