class_name UdpIoListenThreadUdpByte
extends Node

signal on_message_received(data: PackedByteArray)
signal on_message_received_with_source(data: PackedByteArray, source_ip : String, source_port : int)

@export var _port_id: int = 3615
@export var _ip_address_mask: String = "0.0.0.0"
@export var _thread_priority: Thread.Priority = Thread.Priority.PRIORITY_NORMAL
@export var _time_before_start_thread: float = 0.1
@export var _auto_start_server:bool= true


var _received_messages: Array[PackedByteArray] = []
var _received_messages_with_source: Array[Dictionary] = []
var _last_received: PackedByteArray
var _want_thread_alive: bool = true
var _thread_listener: Thread = null
var _udp: PacketPeerUDP = null
var _has_been_killed: bool = false
var _mutex: Mutex = null
var _is_listening: bool = false



func _ready() -> void:
	
	if _auto_start_server:
		await get_tree().create_timer(_time_before_start_thread).timeout
		_start_listening()

## Call this before _ready() to change the port
func set_port_before_start(port: int) -> void:
	_port_id = port

func set_ip_address_mask_before_start(ip_address_mask: String) -> void:
	_ip_address_mask = ip_address_mask

func set_ip_address_mask_and_port_before_start(ip_address_mask: String, port: int) -> void:
	_ip_address_mask = ip_address_mask
	_port_id = port

func set_ip_address_mask_and_port_then_start_server(ip_address_mask: String, port: int) -> void:
	_ip_address_mask = ip_address_mask
	_port_id = port
	_start_listening()

func set_listening_port_and_start_server(port:int):
	if _is_listening:
		printerr("You can't start an already launch thread in this code")
		return 
	_port_id = port
	_start_listening()


func _start_listening() -> void:
	print("UDP Listener: Listening bytes on port %d" % _port_id)	
	_mutex = Mutex.new()
	_thread_listener = Thread.new()
	_thread_listener.start(_check_udp_message_incoming, _thread_priority)
	_is_listening = true


func _process(_delta: float) -> void:
	_push_on_main_thread_message()

func _exit_tree() -> void:
	if not _has_been_killed:
		kill()

func kill() -> void:
	_want_thread_alive = false
	_has_been_killed = true
	_is_listening = false
	
	if _udp:
		_udp.close()
		_udp = null
	
	if _thread_listener and _thread_listener.is_started():
		_thread_listener.wait_to_finish()
		_thread_listener = null

func get_last_received() -> PackedByteArray:
	return _last_received

func is_listening() -> bool:
	return _is_listening

func _push_on_main_thread_message() -> void:
	if _mutex == null:
		return
	
	_mutex.lock()
	
	while _received_messages.size() > 0:
		_last_received = _received_messages.pop_front()
		on_message_received.emit(_last_received)
	
	while _received_messages_with_source.size() > 0:
		var msg: Dictionary = _received_messages_with_source.pop_front()
		on_message_received_with_source.emit(
			msg.data,
			msg.source_ip,
			msg.source_port
		)
	_mutex.unlock()

func _check_udp_message_incoming() -> void:
	_udp = PacketPeerUDP.new()
	var result: Error = _udp.bind(_port_id, _ip_address_mask)
	
	if result != OK:
		push_error("UDP Listener: Failed to bind to port %d - Error: %s" % [_port_id, result])
		return
	
	while _want_thread_alive:
		if _udp.get_available_packet_count() > 0:
			var data: PackedByteArray = _udp.get_packet()
			var source_ip: String = _udp.get_packet_ip()
			var source_port: int = _udp.get_packet_port()
			
			_mutex.lock()
			_received_messages.append(data)
			_received_messages_with_source.append({
				"data": data,
				"source_ip": source_ip,
				"source_port": source_port
			})
			_mutex.unlock()
		else:
			# Small delay to prevent busy-waiting
			OS.delay_msec(1)
	
	if _udp:
		_udp.close()
		_udp = null


func _on_to_macro_of_one_or_two_char_on_request_of_one_char_command(one_char: int) -> void:
	pass # Replace with function body.
