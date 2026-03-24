extends Camera2D



@export var target: CharacterBody2D

func _physics_process(_delta):
	global_position = target.global_position.round()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
