extends Node2D

export(String) var group_node_expected
export(String, FILE) var base_node
var node_expected_on_shape = []
var can_get = false
var mouse_over = false
onready var main = get_tree().get_current_scene()
var occupied = false

func input_type():
	return get_parent().input_type

func _ready():
#	randomize()
#	var x = str(int(rand_range(1,4)))
	if base_node:
		unparent(null,self)
	main.connect("drag_node",self,"another_node_is_dragged")
	self.z_index = get_parent().z_index
	var shape = $area/col.shape.duplicate()
	$area/col.shape = shape
	$area/col.shape.set_extents((($s.get_rect().size) * $s.scale) /4)

func another_node_is_dragged(node,second_node):
	if self == second_node or self == node:
		mouse_over = true
	else:
		mouse_over = false

func _on_Area2D_area_entered(area):
	#if area.is_in_group(group_node_expected):
	#	if area.get_parent().z_index > get_parent().z_index :
	#		add_expected_node(area.get_parent())
	#		area.get_parent().over_place = true
	var input_value = area.get_parent()
	if input_value == get_parent():
		return
	if input_value.matches_type(input_type()):
		if input_value.z_index > get_parent().z_index :
			add_expected_node(input_value)
			input_value.over_place = true
	else:
		input_value.bad_type_error()

func bad_type_error():
	return

func matches_type(type):
	return false

func _on_Area2D_area_exited(area):
	#if area.is_in_group(group_node_expected):
	#	area.get_parent().over_place = false
	#	remove_expected_node(area.get_parent())
	var input_value = area.get_parent()
	input_value.over_place = false
	remove_expected_node(input_value)

func add_expected_node(node):
	node.about_to_be_placed()
	node_expected_on_shape.append(node)

func remove_expected_node(node):
	node.not_about_to_be_placed()
	node_expected_on_shape.remove(node_expected_on_shape.find(node))

func _process(delta):
	self.z_index = get_parent().z_index + 1
	#for x in node_expected_on_shape:
	if node_expected_on_shape.size() > 0:
		$s.modulate = Color(1,1,0,0.3)
		can_get = true
	else:
		$s.modulate = Color(0.6,0.6,0.6,0.3)
		can_get = false
	if Input.is_action_just_released("click") && can_get && !occupied:
		for x in node_expected_on_shape:
			if x.last_node_dragged:
				unparent(x,self)
				return

func unparent(node_to_unparent,target):
	if !node_to_unparent:
		var source = load(base_node)
		var node = source.instance()
		target.add_child(node)
		node.placed(target)
	else:
		occupied = !occupied
		#var node_group = node_to_unparent.piece_nb
		#var node_type = node_to_unparent.type
		#var old_z_index = node_to_unparent.z_index
		#var old_size = node_to_unparent.scale
		#if main.sprites.has(node_to_unparent):
		#	main._remove_sprite(node_to_unparent)
		#node_to_unparent.queue_free()
		#var source = load(node_to_unparent.get_filename())
		#var node = source.instance()
		#node.piece_nb = node_group
		#node.type = node_type
		var node = node_to_unparent
		node.get_parent().remove_child(node)
		target.add_child(node)
		node.placed(target)
		if(target == self):
			get_parent().apply(node)
			node.mouse_over = true
			node.mouse_clicked = false
			node.node_dragged = false
			emit_signal("drag_node",node,null)
		else:
			get_parent().unapply()
			node.mouse_over = true
			node.is_draggable = true
			node.last_node_dragged = true

		#node.is_unplacable = false
		#node.over_place = true
		node.global_position = $s.global_position + node.offset_when_applied()
		#node.z_index = old_z_index
		#node.scale = old_size

func _on_Area2D_mouse_entered():
	main._add_sprite(self)

func _on_Area2D_mouse_exited():
	main._remove_sprite(self)
