class_name UdpIoParseBytePackageToIID
extends Node

signal on_integer_found(value: int)
signal on_integer_date_found(value: int, date_ulong: int)
signal on_index_integer_found(index: int, value: int)
signal on_index_integer_date_found(index: int, value: int, date_ulong: int)

func parse_byte_in_litte_endian_package_to_iid(byte_package: PackedByteArray) -> void:
	match byte_package.size():
		16:
			var index := byte_array_to_int32_little_endian(byte_package.slice(0, 4))
			var value := byte_array_to_int32_little_endian(byte_package.slice(4, 8))
			var date_ulong := byte_array_to_ulong64_little_endian(byte_package.slice(8, 16))
			on_index_integer_date_found.emit(index, value, date_ulong)

		12:
			var value := byte_array_to_int32_little_endian(byte_package.slice(0, 4))
			var date_ulong := byte_array_to_ulong64_little_endian(byte_package.slice(4, 12))
			on_integer_date_found.emit(value, date_ulong)

		8:
			var index := byte_array_to_int32_little_endian(byte_package.slice(0, 4))
			var value := byte_array_to_int32_little_endian(byte_package.slice(4, 8))
			on_index_integer_found.emit(index, value)

		4:
			var value := byte_array_to_int32_little_endian(byte_package)
			on_integer_found.emit(value)

		_:
			push_warning("Unsupported packet size: %d bytes" % byte_package.size())

func byte_array_to_int32_little_endian(bytes: PackedByteArray) -> int:
	assert(bytes.size() == 4)
	return (
		bytes[0]
		| (bytes[1] << 8)
		| (bytes[2] << 16)
		| (bytes[3] << 24)
	)


func byte_array_to_ulong64_little_endian(bytes: PackedByteArray) -> int:
	assert(bytes.size() == 8)
	return (
		int(bytes[0])
		| (int(bytes[1]) << 8)
		| (int(bytes[2]) << 16)
		| (int(bytes[3]) << 24)
		| (int(bytes[4]) << 32)
		| (int(bytes[5]) << 40)
		| (int(bytes[6]) << 48)
		| (int(bytes[7]) << 56)
	)
