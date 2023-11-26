extends Node

func get_timestamp_ms(unix_time: float) -> int:
	return int(unix_time) * 1000 + int(fmod(unix_time, 1.0) * 1000)
	
func get_timestamp_us(unix_time: float) -> int:
	return int(unix_time) * 1000000 + int(fmod(unix_time, 1.0) * 1000000)

func get_timestamp_ns(unix_time: float) -> int:
	return int(unix_time) * 1000000000 + int(fmod(unix_time, 1.0) * 1000000000)

func get_fractional_dict_from_timestamp_ns(timestamp_ns: int) -> Dictionary:
	var ns: int = timestamp_ns % 1000000000
	var ms: int = ns / 1000000
	ns %= 1000000
	var us: int = ns / 1000
	ns %= 1000
	return {'millisecond': ms, 'microsecond': us, 'nanosecond': ns}

func get_fractional_dict_from_timestamp_us(timestamp_us: int) -> Dictionary:
	var us: int = timestamp_us % 1000000
	var ms: int = us / 1000
	us %= 1000
	return {'millisecond': ms, 'microsecond': us}

func get_fractional_dict_from_timestamp_ms(timestamp_ms: int) -> Dictionary:
	return {'millisecond': timestamp_ms % 1000}

