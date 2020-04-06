extends "res://scripts/obj_script_DnD.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
export(String) var input_type
export(String) var return_type
var applied_param_type = null
	
func offset_when_applied():
	return Vector2(100, 0)

func type():
	if applied_param_type:
		return [return_type]
	else:
		return [applied_param_type, return_type]

func apply(value):
	applied_param_type = value.type()

func unapply():
	applied_param_type = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
