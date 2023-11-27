@tool
extends HBoxContainer
## Node for drawing any horizontal text in monospace.
## The text is specified in the property "label".

## The text to display.
@export var label: String = '':
	set(value):
		if label != value:
			label = value
			update_label()

## The font of the text can be overridden if the theme's font is not desired.
## Set this to [code]null[/code] to use the theme's font.
@export var font_override: Font = null:
	set(value):
		if font_override != value:
			font_override = value
			update_font()
			update_letter_size()

## The font size of the text can be overridden if the theme's font size is not
## desired. Set this to 0 to use the theme's font size.
@export var font_size_override: int = 0:
	set(value):
		if font_size_override != value:
			font_size_override = value
			update_font_size()
			update_letter_size()

## The size of each letter can be overridden if the calculated size is not
## desired. Set this to (0, 0) to use the calculated size.
@export var letter_size_override: Vector2i = Vector2i.ZERO:
	set(value):
		if letter_size_override != value:
			letter_size_override = value
			letter_size = letter_size_override
			update_letter_size()

# Cached font.
var font: Font = null

## Returns the cached font if it exists, or retrieves the default theme's font,
## caches it, and returns it.
func safe_font():
	if font:
		return font
	font = get_theme_default_font()
	return font

# Cached font size.
var font_size: int = 0

## Returns the cached font size if it exists, or retrieves the default theme's
## font_size, caches it, and returns it.
func safe_font_size():
	if font_size:
		return font_size
	font_size = get_theme_default_font_size()
	return font_size

## Cached letter size.
var letter_size: Vector2i = Vector2i.ZERO

## Returns the cached letter size if it exists, or computes it, caches it, and
## returns it.
func safe_letter_size():
	if letter_size:
		return letter_size
	letter_size = Vector2i.ZERO
	var cur_font = safe_font()
	var cur_font_size = safe_font_size()
	for ch in CHARS:
		var char_size = cur_font.get_char_size(ch, cur_font_size)
		letter_size.x = max(letter_size.x, char_size.x)
		letter_size.y = max(letter_size.y, char_size.y)
	return letter_size

# A set of characters to use in computing the letter size.
var CHARS: PackedInt32Array = \
	'0123456789:.ampAMP'.to_utf32_buffer().to_int32_array()


func update_font():
	font = font_override
	var cur_font = safe_font()
	for ch in get_children():
		ch.remove_theme_font_override('font')
		ch.add_theme_font_override('font', cur_font)


func update_font_size():
	font_size = font_size_override
	var cur_font_size = safe_font_size()
	for ch in get_children():
		ch.remove_theme_font_size_override('font_size')
		ch.add_theme_font_size_override('font_size', cur_font_size)


func update_letter_size():
	letter_size = letter_size_override
	var cur_letter_size = safe_letter_size()
	for ch in get_children():
		ch.custom_minimum_size = Vector2(
			cur_letter_size.x, cur_letter_size.y)


func update_label():
	for ch in get_children():
		remove_child(ch)
		ch.queue_free()
	
	var cur_font = safe_font()
	var cur_font_size = safe_font_size()
	for i in len(label):
		var ch = Label.new()
		ch.text = label[i]
		ch.clip_text = true
		ch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ch.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ch.size_flags_horizontal = 0
		ch.size_flags_vertical = 0
		ch.add_theme_font_override('font', cur_font)
		ch.add_theme_font_size_override('font_size', cur_font_size)
		ch.custom_minimum_size = Vector2(
			safe_letter_size().x, safe_letter_size().y)
		add_child(ch)


func update_theme_properties():
	update_font()
	update_font_size()
	update_letter_size()


func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			update_theme_properties()

