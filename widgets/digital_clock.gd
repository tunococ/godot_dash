@tool
extends Control

@export_group('Text Appearance')
# Delegated properties
@export var font_override: Font = null:
	set(value):
		$Text.font_override = value
	get:
		return $Text.font_override

@export var font_size_override: int = 0:
	set(value):
		$Text.font_size_override = value
	get:
		return $Text.font_size_override

@export var letter_size_override: Vector2i = Vector2i.ZERO:
	set(value):
		$Text.letter_size_override = value
	get:
		return $Text.letter_size_override


@export_group('Time Format')

@export_flags('12-hour', '0-padded') var hour_format: int:
	set(value):
		hour_format = value
		update_format()

@export var show_seconds: bool = true:
	set(value):
		show_seconds = value
		notify_property_list_changed()
		update_format()

var decimals: int = 0:
	set(value):
		decimals = value
		update_format()

var format_string: String = ''
var num_args: int = 0
var text_len: int = 0

# Update format_string, num_args, and text_len based on exported properties.
func update_format():
	
	# Start with "HH:MM".
	num_args = 2
	text_len = 5

	if hour_format & 2:
		# Pad with zero.
		format_string = '%02d:%02d'
	else:
		# Do not pad.
		format_string = '%2d:%02d'
	
	if show_seconds:
		# Add ":SS".
		num_args += 1
		text_len += 3
		format_string += ':%02d'
		
		if decimals > 0:
			# Add ".XXX" for fraction of a second.
			num_args += 1
			text_len += 1 + decimals
			format_string += '.%0' + str(decimals) + 'd'
	
	if hour_format & 1:
		# Add " am" or " pm".
		num_args += 1
		text_len += 3
		format_string += ' %s'


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if show_seconds:
		list.append(
			{
				'name': 'decimals',
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_RANGE,
				'hint_string': '0,3,1',
			}
		)
	return list


func get_time_text(
	hours: int = 0,
	minutes: int = 0,
	seconds: int = 0,
	milliseconds: int = 0,
) -> String:
	
	var ms_of_day = (
		(hours * 60 + minutes) * 60 + seconds) * 1000 + milliseconds
	var pm: bool = ms_of_day >= 43200000
	
	if hour_format & 1:
		hours %= 12
		if hours == 0:
			hours = 12
	
	var args: Array = [hours, minutes]
	
	if show_seconds:
		args.append(seconds)
		
		if decimals > 0:
			# decimals come from the numerator of a quotient in which
			# the denominator is 10 ** (# of digits).
			if decimals == 1:
				args.append(milliseconds / 100)
			elif decimals == 2:
				args.append(milliseconds / 10)
			else:
				args.append(milliseconds)
					
	if hour_format & 1:
		args.append("pm" if pm else "am")
	
	var output = format_string % args
	
	return output


func show_timestamp_ms(timestamp_ms: int):
	var td: Dictionary = Time.get_time_dict_from_unix_time(timestamp_ms / 1000)
	$Text.label = get_time_text(
		td.hour, td.minute, td.second, timestamp_ms % 1000)


func _process(_delta):
	var timestamp_ms: int = 0
	if !Engine.is_editor_hint():
		timestamp_ms = TimeUtils.get_timestamp_ms(
			Time.get_unix_time_from_system()
		)
		
	var time_zone = Time.get_time_zone_from_system()
	timestamp_ms += time_zone.get('bias', 0) * 60000
	show_timestamp_ms(timestamp_ms)


