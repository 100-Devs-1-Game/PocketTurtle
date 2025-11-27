extends RichTextLabel
## A minimal [RichTextLabel] wrapper that takes a text file and parses it. The font size, font color, 
## outline color, outline size, and font for the title of each section is taken from the [Theme] 
## type HeaderMedium. Other properties are ignored.


const _THEME_TYPE_HEADER:StringName = &"HeaderMedium"


@export_file("*.txt") var credits_path:String
@export_file("component_credits.txt") var component_credits:Array[String]

#region Themecache
var tc_header_font_color:Color
var tc_font_outline_color:Color
var tc_outline_size:int
var tc_header_font:Font
var tc_header_font_size:int
#endregion Themecache


func _ready() -> void:
	if not FileAccess.file_exists(credits_path):
		push_error("Can't find credits file")
		return

	load_credits(FileAccess.open(credits_path, FileAccess.READ))


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		tc_header_font_color = get_theme_color(&"font_color", _THEME_TYPE_HEADER)
		tc_font_outline_color = get_theme_color(&"font_outline_color", _THEME_TYPE_HEADER)
		tc_outline_size = get_theme_constant(&"outline_size", _THEME_TYPE_HEADER)
		tc_header_font = get_theme_font(&"font", _THEME_TYPE_HEADER)
		tc_header_font_size = get_theme_font_size(&"font_size", _THEME_TYPE_HEADER)


func load_credits(file:FileAccess) -> void:
	var current_section_credits:PackedStringArray = []
	
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		if line.begins_with("- "):
			current_section_credits.append(line.lstrip("- "))
			continue
		# Otherwise, New section
		add_section(current_section_credits)
		add_section_header(line)
		current_section_credits.clear()
	add_section(current_section_credits)
	file.close()

	var extra_contributors: PackedStringArray
	
	for component_credits_path in component_credits:
		if not FileAccess.file_exists(component_credits_path):
			push_error("Couldn't find component credits")
			return
			
		var s:= FileAccess.get_file_as_string(component_credits_path)
		for contributor in s.split("\r\n", false):
			extra_contributors.append(contributor)
			
	add_section_header("Thanks to:")
	add_text(", ".join(extra_contributors))


func add_section(section_credits:PackedStringArray) -> void:
	section_credits.sort()
	for credit in section_credits:
		add_text(credit + "\n")
	add_text("\n")


func add_section_header(header:String) -> void:
	push_context()
	push_bold()
	push_color(tc_header_font_color)
	push_outline_color(tc_font_outline_color)
	push_outline_size(tc_outline_size)
	push_font(tc_header_font, tc_header_font_size)
	add_text(header + "\n")
	pop_context()
