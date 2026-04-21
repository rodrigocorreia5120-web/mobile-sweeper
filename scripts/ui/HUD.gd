extends Control

signal reveal_requested
signal flag_requested
signal restart_requested

const COLOR_REVEAL := Color("#4FCB6B")
const COLOR_REVEAL_ACTIVE := Color("#6CDE84")

const COLOR_FLAG := Color("#D64545")
const COLOR_FLAG_ACTIVE := Color("#E35C5C")

const COLOR_RESTART := Color("#666A73")
const COLOR_RESTART_ACTIVE := Color("#7A7F89")

const COLOR_TEXT := Color.BLACK
const COLOR_BORDER := Color("#14263a")

@onready var reveal_button: Button = $RevealButton
@onready var flag_button: Button = $FlagButton
@onready var restart_button: Button = $RestartButton
@onready var mode_label: Label = $ModeLabel
@onready var status_label: Label = $StatusLabel
@onready var bomb_count_label: Label = $BombCountLabel
@onready var flag_count_label: Label = $FlagCountLabel

func _ready() -> void:
	if not reveal_button.pressed.is_connected(_on_reveal_button_pressed):
		reveal_button.pressed.connect(_on_reveal_button_pressed)

	if not flag_button.pressed.is_connected(_on_flag_button_pressed):
		flag_button.pressed.connect(_on_flag_button_pressed)

	if not restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.connect(_on_restart_button_pressed)

	_setup_ui()
	set_mode("reveal")
	set_status("")
	set_counters(0, 0)

func _setup_ui() -> void:
	reveal_button.text = "Reveal"
	flag_button.text = "Flag"
	restart_button.text = "Restart"

	reveal_button.custom_minimum_size = Vector2(140, 60)
	flag_button.custom_minimum_size = Vector2(140, 60)
	restart_button.custom_minimum_size = Vector2(140, 60)

	mode_label.text = "Mode: Reveal"
	status_label.text = ""
	bomb_count_label.text = "Bombs: 0"
	flag_count_label.text = "Flags Left: 0"

	_setup_label_colors()
	_apply_button_styles("reveal")

func _setup_label_colors() -> void:
	mode_label.modulate = COLOR_TEXT
	status_label.modulate = COLOR_TEXT
	bomb_count_label.modulate = COLOR_TEXT
	flag_count_label.modulate = COLOR_TEXT

func set_mode(mode: String) -> void:
	mode_label.text = "Mode: " + mode.capitalize()
	_apply_button_styles(mode)

func set_status(text: String) -> void:
	status_label.text = text
	status_label.modulate = COLOR_TEXT

func set_counters(total_bombs: int, flags_left: int) -> void:
	bomb_count_label.text = "Bombs: " + str(total_bombs)
	flag_count_label.text = "Flags Left: " + str(flags_left)
	bomb_count_label.modulate = COLOR_TEXT
	flag_count_label.modulate = COLOR_TEXT

func _apply_button_styles(active_mode: String) -> void:
	_style_button(reveal_button, COLOR_REVEAL_ACTIVE if active_mode == "reveal" else COLOR_REVEAL)
	_style_button(flag_button, COLOR_FLAG_ACTIVE if active_mode == "flag" else COLOR_FLAG)
	_style_button(restart_button, COLOR_RESTART)

func _style_button(button: Button, base_color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.border_color = COLOR_BORDER
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_right = 6
	normal.corner_radius_bottom_left = 6

	var hover := StyleBoxFlat.new()
	hover.bg_color = base_color.lightened(0.08)
	hover.border_color = COLOR_BORDER
	hover.border_width_left = 2
	hover.border_width_top = 2
	hover.border_width_right = 2
	hover.border_width_bottom = 2
	hover.corner_radius_top_left = 6
	hover.corner_radius_top_right = 6
	hover.corner_radius_bottom_right = 6
	hover.corner_radius_bottom_left = 6

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = base_color.darkened(0.12)
	pressed.border_color = COLOR_BORDER
	pressed.border_width_left = 2
	pressed.border_width_top = 2
	pressed.border_width_right = 2
	pressed.border_width_bottom = 2
	pressed.corner_radius_top_left = 6
	pressed.corner_radius_top_right = 6
	pressed.corner_radius_bottom_right = 6
	pressed.corner_radius_bottom_left = 6

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = base_color.darkened(0.25)
	disabled.border_color = COLOR_BORDER.darkened(0.2)
	disabled.border_width_left = 2
	disabled.border_width_top = 2
	disabled.border_width_right = 2
	disabled.border_width_bottom = 2
	disabled.corner_radius_top_left = 6
	disabled.corner_radius_top_right = 6
	disabled.corner_radius_bottom_right = 6
	disabled.corner_radius_bottom_left = 6

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT.darkened(0.2))

func _on_reveal_button_pressed() -> void:
	reveal_requested.emit()

func _on_flag_button_pressed() -> void:
	flag_requested.emit()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()
