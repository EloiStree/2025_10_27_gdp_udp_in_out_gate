class_name UdpIoParseTextPackageToIID
extends Node


signal on_integer_found(value:int)
signal on_index_integer_found(index:int,value:int)
signal on_index_integer_date_found(index:int, value:int, date_ulong:int)
signal on_index_integer_date_array_found(array_iid:Array[int])


@export var _splitter: String = ":"
@export var _last_integer_found: String = "0"
@export var _last_index_integer_found: String = "0"
@export var _last_index_integer_date_found: String = "0"
@export var _last_iid_array_element_count_found: int = 0

func parse_text_package_to_iid(text_package:String) -> void:
	var parts = text_package.split(_splitter)
	
	if parts.size() == 3:
		var index = int(parts[0])
		var value = int(parts[1])
		var date_ulong = int(parts[2])
		_last_index_integer_date_found = text_package
		on_index_integer_date_found.emit(index, value, date_ulong)
	
	elif parts.size() == 2:
		var index = int(parts[0])
		var value = int(parts[1])
		_last_index_integer_found = text_package
		on_index_integer_found.emit(index, value)
	
	elif parts.size() == 1:
		var value = int(parts[0])
		_last_integer_found = text_package
		on_integer_found.emit(value)

	elif parts.size() % 3 == 0:
		var element_count = parts.size() / 3
		var integer: Array[int] = [element_count]
		for i in range(0, parts.size(), 3):
			var index = int(parts[i]) 
			var value = int(parts[i + 1])
			var date_ulong = int(parts[i + 2])
			integer.append(index)
			integer.append(value)
			integer.append(date_ulong)
		_last_iid_array_element_count_found = integer.size()
		on_index_integer_date_array_found.emit(integer)
