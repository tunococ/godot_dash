@tool
extends HBoxContainer

@export var label: String = '':
	set(value):
		if label != value:
			label = value
			update_label()


@export var font_override: Font = null:
	set(value):
		if font_override != value:
			font_override = value
			update_font()
			update_letter_size()


@export var font_size_override: int = 0:
	set(value):
		if font_size_override != value:
			font_size_override = value
			update_font_size()
			update_letter_size()


@export var letter_size_override: Vector2i = Vector2i.ZERO:
	set(value):
		if letter_size_override != value:
			letter_size_override = value
			letter_size = letter_size_override
			update_letter_size()


var font: Font = null

func safe_font():
	if font:
		return font
	font = get_theme_default_font()
	return font


var font_size: int = 0

func safe_font_size():
	if font_size:
		return font_size
	font_size = get_theme_default_font_size()
	return font_size


var letter_size: Vector2i = Vector2i.ZERO

func safe_letter_size():
	if letter_size:
		return letter_size
	letter_size = Vector2i.ZERO
	for ch in safe_CHARS():
		var char_size = safe_font().get_char_size(ch, safe_font_size())
		letter_size.x = max(letter_size.x, char_size.x)
		letter_size.y = max(letter_size.y, char_size.y)
	return letter_size


var CHARS: PackedInt32Array = PackedInt32Array([])

func safe_CHARS():
	if !CHARS.is_empty():
		return CHARS
	CHARS = '0123456789:.ampAMP'.to_utf32_buffer().to_int32_array()
	return CHARS


func update_font():
	font = font_override
	for ch in get_children():
		ch.add_theme_font_override('font', safe_font())


func update_font_size():
	font_size = font_size_override
	for ch in get_children():
		ch.add_theme_font_size_override('font_size', safe_font_size())


func update_letter_size():
	letter_size = letter_size_override
	for ch in get_children():
		ch.custom_minimum_size = Vector2(
			safe_letter_size().x, safe_letter_size().y)
	

func update_label():
	for ch in get_children():
		remove_child(ch)
		ch.queue_free()
	
	var style_box = StyleBox.new()
	style_box.set_content_margin_all(0)
	
	for i in len(label):
		var ch = Label.new()
		ch.text = label[i]
		ch.clip_text = true
		ch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ch.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ch.size_flags_horizontal = 0
		ch.size_flags_vertical = 0
		ch.add_theme_font_override('font', safe_font())
		ch.add_theme_font_size_override('font_size', safe_font_size())
#		ch.add_theme_stylebox_override('normal', style_box)
		ch.custom_minimum_size = Vector2(
			safe_letter_size().x, safe_letter_size().y)
		add_child(ch)
