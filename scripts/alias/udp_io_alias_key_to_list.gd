
## Ask to send the information to Paul, you dont care of the ip or mdns and port.
class_name UdpIoAliasKeyToListBroadcaster
extends Node


@export var _alias_to_list_of_targets_bytes: Dictionary[String, Array] = {
	"Paul": ["127.0.0.1:3615","192.168.178.163:7073","192.168.178.185:7073"]
}
@export var _alias_to_list_of_targets_text: Dictionary[String, Array] = {
	"Paul": ["127.0.0.1:3614"]
}

func send_bytes_to_target(ip: String, port: int, bytes: PackedByteArray) -> void:
	var udp := PacketPeerUDP.new()
	# Bind to a free local port so the socket exists, but do not wait for any reply.
	# UDP does not require the remote host to be listening/connected.
	udp.bind(0)
	udp.set_dest_address(ip, port)
	udp.put_packet(bytes)
	udp.close()

func send_bytes_to_alias(alias: String, bytes: PackedByteArray) -> void:
	if _alias_to_list_of_targets_bytes.has(alias):
		for target in _alias_to_list_of_targets_bytes[alias]:
			var ip_port = target.split(":")
			var ip = ip_port[0]
			var port = int(ip_port[1])
			print("HEEEER", alias, bytes, ip, port)
			send_bytes_to_target(ip, port, bytes)

func send_text_to_alias(alias: String, text: String) -> void:
	if _alias_to_list_of_targets_text.has(alias):
		for target in _alias_to_list_of_targets_text[alias]:
			var ip_port = target.split(":")
			var ip = ip_port[0]
			var port = int(ip_port[1])
			send_bytes_to_target(ip, port, text.to_utf8_buffer())

func send_random_integer_little_endian_to_alias(alias: String) -> void:
	var random_int = randi() % 1000
	send_bytes_to_alias(alias, get_packed_byte_array_from_integer(random_int))

func send_random_integer_little_endian_to_all_bytes_aliases() -> void:
	for alias in _alias_to_list_of_targets_bytes.keys():
		send_random_integer_little_endian_to_alias(alias)

func send_integer_to_all(integer_value: int) -> void:
	for alias in _alias_to_list_of_targets_bytes.keys():
		send_bytes_to_alias(alias, get_packed_byte_array_from_integer(integer_value))

func send_integer_index_to_all(index: int,value: int) -> void:
	for alias in _alias_to_list_of_targets_bytes.keys():
		send_bytes_to_alias(alias, get_packed_byte_array_from_integer_index(index, value))


func send_integer_to_alias(alias: String, integer_value: int) -> void:

	send_bytes_to_alias(alias, get_packed_byte_array_from_integer(integer_value))

func send_integer_index_to_alias(alias: String, index: int,value: int) -> void:
	send_bytes_to_alias(alias, get_packed_byte_array_from_integer_index(index, value))


func get_packed_byte_array_from_integer(integer_value: int) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.append(integer_value & 0xFF)
	bytes.append((integer_value >> 8) & 0xFF)
	bytes.append((integer_value >> 16) & 0xFF)
	bytes.append((integer_value >> 24) & 0xFF)
	return bytes

func get_packed_byte_array_from_integer_index(index: int, value: int) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.append(index & 0xFF)
	bytes.append((index >> 8) & 0xFF)
	bytes.append((index >> 16) & 0xFF)
	bytes.append((index >> 24) & 0xFF)
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	bytes.append((value >> 16) & 0xFF)
	bytes.append((value >> 24) & 0xFF)
	return bytes


func send_text_to_all_aliases(text: String) -> void:
	for alias in _alias_to_list_of_targets_text.keys():
		send_text_to_alias(alias, text)	

func send_bytes_to_all_aliases(bytes: PackedByteArray) -> void:
	for alias in _alias_to_list_of_targets_bytes.keys():
		send_bytes_to_alias(alias, bytes)
