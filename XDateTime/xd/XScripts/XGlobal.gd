extends Reference
class_name XGlobal

const INT_MIN = -9223372036854775807
const INT_MAX =  9223372036854775806

# 20210529
enum Type{
	ANY = TYPE_NIL,
	BOOL = TYPE_BOOL,
	INT = TYPE_INT,
	REAL = TYPE_FLOAT,
	STRING = TYPE_STRING,
	DICTIONARY = TYPE_DICTIONARY,
	COLOR = TYPE_COLOR,
	BIT_MASK = TYPE_MAX + 1
}

enum TimeUnit{
	YEAR,MONTH,DAY,WEEK,HOUR,MINUTE,SECOND
}


static func copy_file(from, to):
	var file_from = from.replace("/","\\")
	var file_to = to.replace("/","\\")
	OS.execute("copy",[file_from,file_to])


static func print(value):
	var st = get_stack()[1]
	print("%s \t %s(%s:%s)"%[value,st[str("source")],st[str("function")],st[str("line")]])


static func get_all_type_nodes(root:Node,type)->Array:
	var nodes = []
	if root is type:
		nodes.append(root)
	
	for i in root.get_children():
		var nds = get_all_type_nodes(i, type)
		for nd in nds:
			nodes.append(nd)
	
	return nodes

static func raycast_from_mouse(mouse_pos,camera:Camera3D,  ray_length=1000, collision_mask=0x7FFFFFFF, 
		collide_with_bodies = true, collide_with_areas = true):
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_start + camera.project_ray_normal(mouse_pos)*ray_length
	var space_state = camera.get_world().direct_space_state
	return space_state.intersect_ray(ray_start,ray_end,[],collision_mask,
		collide_with_bodies , collide_with_areas)


static func find_node_by_class(root:Node,cls_name:String)->Node:
	assert(root)
	
	if root.is_class(cls_name):
		return root
	
	for i in root.get_children():
		var ret = find_node_by_class(i,cls_name)
		if ret:
			return ret
	
	return null

static func select_option_button_item_by_id(btn:OptionButton, id:int):
	var count = btn.get_item_count()
	for i in count:
		if btn.get_item_id(i)==id:
			btn.select(i)
			return


static func select_option_button_item_by_text(btn:OptionButton, text:String):
	var count = btn.get_item_count()
	for i in count:
		if btn.get_item_text(i)==text:
			btn.select(i)
			return


static func compare_array(arr1:Array,arr2:Array)->int:
	assert(arr1.size()==arr2.size())
	for i in arr1.size():
		var type = typeof(arr1[i])
		var rs = 0
		match type:
			TYPE_INT,TYPE_FLOAT:
				rs = arr1[i]-arr2[i]
			TYPE_OBJECT:
				rs = arr1[i].compare(arr1[i],arr2[i])
			_:
				assert(false)
				return 0
		if rs>0:
			return 1
		if rs<0:
			return -1
	return 0
