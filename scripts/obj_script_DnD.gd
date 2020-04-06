extends Node

export(String) var piece_nb
export(String) var type

var mouse_over = false
var mouse_clicked = false
var node_dragged = false
var is_draggable = false
var last_node_dragged = false

var is_unplacable = false
var over_place = false
var node_placed_in = null
var mouse_pos_distance

onready var main = get_tree().get_current_scene()

func _ready():
#	randomize()
#	var x =str(int(rand_range(1,4)))
	$s.texture = load("res://assets/computer_pieces/piece_"+piece_nb+".png")
	$s_shadow.texture = $s.texture
	if piece_nb :
		$area.add_to_group(piece_nb,true)
	$s.material.set_shader_param("outline_color",Color(0,0,0))
	var mat = $s.get_material().duplicate()
	$s.set_material(mat)
	main.connect("drag_node",self,"another_node_is_dragged")
	var shape = $area/col.shape.duplicate()
	$area/col.shape = shape
	$area/col.shape.set_extents((($s.get_rect().size) * $s.scale) /2)

func matches_type(expected_type):
	return [expected_type] == type()

func type():
	return [type]

func placed(node_in):
	if node_in != main.get_node("phone_tree_container"):
		node_placed_in = node_in
	else:
		node_placed_in = null

func another_node_is_dragged(z_top,un_used):
	last_node_dragged = false
	if self == z_top && ! node_dragged:
		$s.material.set_shader_param("outline_color",Color(1,1,1))
		if !node_placed_in:
			is_draggable = true
		else:
			is_unplacable = true
	elif ! node_dragged :
		$s.material.set_shader_param("outline_color",Color(0,0,0))
		is_draggable = false
		is_unplacable = false

func about_to_be_placed():
	$s.material.set_shader_param("outline_color",Color(0,1,0))

func not_about_to_be_placed():
	$s.material.set_shader_param("outline_color",Color(1,1,1))

func bad_type_error():
	$s.material.set_shader_param("outline_color",Color(1,0,0))

func _process(delta):
	if ! node_placed_in:
		if Input.is_action_pressed("click"):
			if !mouse_clicked && mouse_over:
				node_dragged = true
				mouse_pos_distance = get_viewport().get_mouse_position() - self.global_position
			mouse_clicked = true
		else:
			mouse_clicked = false
			node_dragged = false
		
		if node_dragged && is_draggable:
			main.drag_node(self)
			if $s_shadow.position.x < 20:
				$s_shadow.position = Vector2($s_shadow.position.x +3,$s_shadow.position.y +3)
			self.position = Vector2(self.position.x - 2,self.position.y - 2)
			$Tween.interpolate_property(self,"position",self.position,get_viewport().get_mouse_position() - mouse_pos_distance,0.1,Tween.TRANS_SINE,Tween.EASE_OUT)
			$Tween.start()
			last_node_dragged = true
		else:
			if $s_shadow.position.x > 1:
				$s_shadow.position = Vector2($s_shadow.position.x -3,$s_shadow.position.y -3)
	else:
		self.z_index = node_placed_in.z_index + 1
		#self.global_position = node_placed_in.global_position
		if Input.is_action_just_pressed("unplace") && is_unplacable:
			self.z_index += 2
			node_placed_in.unparent(self,get_tree().get_current_scene().get_node("phone_tree_container"))

func offset_when_applied():
	return Vector2(0,0)

func _on_area_mouse_entered():
	mouse_over = true
	main._add_sprite(self)

func _on_area_mouse_exited():
	mouse_over = false
	main._remove_sprite(self)