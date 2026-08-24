class_name UdpIoPushPackageUdpOutToTargetsGroup
extends Node

@export var list_targets_ipv4_for_bytes: Array[String] = [
	"192.168.137.1:3615",
	"192.168.1.1:3615"
	]
@export var list_targets_ipv4_for_text: Array[String] = [
	"192.168.137.1:3614",
	"192.168.1.1:3614"
	]


func clear_text_targets():
	list_targets_ipv4_for_text.clear()

func clear_byte_targets():
	list_targets_ipv4_for_bytes.clear()

func clear_all_targets():
	clear_text_targets()
	clear_byte_targets()

func append_text_target_ipv4(ipv4_address: String, port: int):
	if is_valide_ipv4_address(ipv4_address):
		var target = ipv4_address + ":" + str(port)
		if not list_targets_ipv4_for_text.has(target):
			list_targets_ipv4_for_text.append(target)

func append_byte_target_ipv4(ipv4_address: String, port: int):
	if is_valide_ipv4_address(ipv4_address):
		var target = ipv4_address + ":" + str(port)
		if not list_targets_ipv4_for_bytes.has(target):
			list_targets_ipv4_for_bytes.append(target)

func set_text_targets_ipv4_from_array(targets: Array[String]):
	list_targets_ipv4_for_text = targets

func set_byte_targets_ipv4_from_array(targets: Array[String]):
	list_targets_ipv4_for_bytes = targets

var udp_socket := PacketPeerUDP.new()
func push_text_to_targets(text_to_send_utf8: String):
	var bytes_to_send = text_to_send_utf8.to_utf8_buffer()
	push_bytes_to_targets(bytes_to_send, true)

func push_bytes_to_targets(bytes_to_send: PackedByteArray, bool_is_text: bool = false):
	var address_list = list_targets_ipv4_for_text if  bool_is_text else  list_targets_ipv4_for_bytes
	for target in address_list:
		var splits = target.split(":")
		var address = splits[0].strip_edges()
		var port = splits[1].strip_edges().to_int()
		if is_valide_ipv4_address(address):
			udp_socket.set_dest_address(address, port)
			udp_socket.put_packet(bytes_to_send)

func is_valide_ipv4_address(ipv4_address: String) -> bool:
	var regex = RegEx.new()
	regex.compile(r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
	return regex.search(ipv4_address) != null


func push_random_text_and_byte():
	push_random_string()
	push_random_integer()


const STRING_RANDOM="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
func push_random_string( text_length: int = 10):
	var random_string = ""
	for i in range(text_length):
		random_string += String(STRING_RANDOM[randi() % STRING_RANDOM.length()]) # Generate random characters from STRING_RANDOM	
	push_text_to_targets(random_string)

	
	
func push_random_integer():
	var bytes_to_send = integer_to_int32_bytes(randi())
	push_bytes_to_targets(bytes_to_send, false)


func push_random_ssd1306_as_byte_array():
	var random_bytes = PackedByteArray()
	# for random 128*64 bit
	for i in range((128*64)/8):
		random_bytes.append(randi() % 256) 
	push_bytes_to_targets(random_bytes, false)

func push_random_ssd1306_as_text():
	var text01 = ""
	for i in range(128*64):
		text01 += String(STRING_RANDOM[randi() % STRING_RANDOM.length()]) # Generate random characters from STRING_RANDOM
	push_text_to_targets(text01)

func push_index_integer_to_targets(index_int32: int, value_int32: int):
	var byte_as_int_index = integer_to_int32_bytes(index_int32)
	var byte_as_int_value = integer_to_int32_bytes(value_int32)

	var bytes_as_indexed_integer = PackedByteArray()
	bytes_as_indexed_integer.append_array(byte_as_int_index)
	bytes_as_indexed_integer.append_array(byte_as_int_value)
	push_bytes_to_targets(bytes_as_indexed_integer,false)


func push_integer_to_targets(value_int32: int):
	var byte_as_int_value = integer_to_int32_bytes(value_int32)
	push_bytes_to_targets(byte_as_int_value,false)


func push_iid_to_targets(index_int32: int, value_int32: int, date_ulong64: int):

	var byte_as_int_index = integer_to_int32_bytes(index_int32)
	var byte_as_int_value = integer_to_int32_bytes(value_int32)
	var byte_as_ulong_date = integer_to_ulong64bytes(date_ulong64)

	var bytes_as_iid = PackedByteArray()
	bytes_as_iid.append_array(byte_as_int_index)
	bytes_as_iid.append_array(byte_as_int_value)
	bytes_as_iid.append_array(byte_as_ulong_date)
	push_bytes_to_targets(bytes_as_iid,false)


func push_integer_pack_as_little_endian_bytes_to_targets(int_pack: PackedInt32Array):
	var bytes_to_send = PackedByteArray()
	for value in int_pack:
		var byte_as_int_value = integer_to_int32_bytes(value)
		bytes_to_send.append_array(byte_as_int_value)
	push_bytes_to_targets(bytes_to_send,false
)

func push_integer_array_as_little_endian_bytes_to_targets(int_array: Array[int]):
	var bytes_to_send = PackedByteArray()
	for value in int_array:
		var byte_as_int_value = integer_to_int32_bytes(value)
		bytes_to_send.append_array(byte_as_int_value)
	push_bytes_to_targets(bytes_to_send,false)




func integer_to_int32_bytes(value_int32: int) -> PackedByteArray:
	var byte_array = PackedByteArray()
	byte_array.resize(4)
	byte_array[0] = value_int32 & 0xFF
	byte_array[1] = (value_int32 >> 8) & 0xFF
	byte_array[2] = (value_int32 >> 16) & 0xFF
	byte_array[3] = (value_int32 >> 24) & 0xFF
	return byte_array

func integer_to_ulong64bytes(value_ulong64: int) -> PackedByteArray:
	var byte_array = PackedByteArray()
	byte_array.resize(8)
	byte_array[0] = value_ulong64 & 0xFF
	byte_array[1] = (value_ulong64 >> 8) & 0xFF
	byte_array[2] = (value_ulong64 >> 16) & 0xFF
	byte_array[3] = (value_ulong64 >> 24) & 0xFF
	byte_array[4] = (value_ulong64 >> 32) & 0xFF
	byte_array[5] = (value_ulong64 >> 40) & 0xFF
	byte_array[6] = (value_ulong64 >> 48) & 0xFF
	byte_array[7] = (value_ulong64 >> 56) & 0xFF
	return byte_array
