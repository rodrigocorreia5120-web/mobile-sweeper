extends Node2D

signal cell_pressed(cell)

const COLOR_HIDDEN := Color("#8FB6D1")
const COLOR_REVEALED := Color("#D7E7F2")
const COLOR_FLAGGED := Color("#F3D55B")
const COLOR_BOMB := Color("#FF7272")
const COLOR_WRONG_FLAG := Color("#FF5C5C")
const COLOR_TEXT_BLACK := Color.BLACK

var q: int = 0
var r: int = 0

var is_bomb: bool = false
var is_revealed: bool = false
var is_flagged: bool = false
var neighbor_bombs: int = 0
var is_wrong_flag: bool = false

@onready var background = $Background
@onready var number_label = $NumberLabel
@onready var flag_label = $FlagLabel
@onready var bomb_label = $BombLabel
@onready var click_area = $ClickArea

func _ready() -> void:
	if not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)
	_setup_label_defaults()
	_refresh_visuals()

func setup(axial_q: int, axial_r: int) -> void:
	q = axial_q
	r = axial_r

func reset_state() -> void:
	is_bomb = false
	is_revealed = false
	is_flagged = false
	neighbor_bombs = 0
	is_wrong_flag = false
	scale = Vector2.ONE
	_refresh_visuals()

func _on_click_area_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_play_tap_feedback()
		emit_signal("cell_pressed", self)

func reveal() -> void:
	if is_revealed:
		return
	if is_flagged:
		return

	is_revealed = true
	_refresh_visuals()

func toggle_flag() -> void:
	if is_revealed:
		return

	is_flagged = not is_flagged
	_refresh_visuals()

func force_show_bomb() -> void:
	if is_bomb:
		is_revealed = true
		_refresh_visuals()

func mark_wrong_flag() -> void:
	if is_flagged and not is_bomb:
		is_wrong_flag = true
		_refresh_visuals()

func _play_tap_feedback() -> void:
	scale = Vector2(0.94, 0.94)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)

func _setup_label_defaults() -> void:
	number_label.visible = false
	flag_label.visible = false
	bomb_label.visible = false

	number_label.text = ""
	flag_label.text = "F"
	bomb_label.text = "B"

	flag_label.modulate = COLOR_TEXT_BLACK
	bomb_label.modulate = COLOR_TEXT_BLACK

func _refresh_visuals() -> void:
	number_label.visible = false
	flag_label.visible = false
	bomb_label.visible = false

	if is_revealed:
		if is_bomb:
			background.modulate = COLOR_BOMB
			bomb_label.visible = true
		else:
			background.modulate = COLOR_REVEALED

			if neighbor_bombs > 0:
				number_label.text = str(neighbor_bombs)
				number_label.modulate = _get_number_color(neighbor_bombs)
				number_label.visible = true
			else:
				number_label.text = ""
	elif is_flagged:
		if is_wrong_flag:
			background.modulate = COLOR_WRONG_FLAG
		else:
			background.modulate = COLOR_FLAGGED

		flag_label.modulate = COLOR_TEXT_BLACK
		flag_label.visible = true
	else:
		background.modulate = COLOR_HIDDEN

func _get_number_color(value: int) -> Color:
	match value:
		1:
			return Color(0.2, 0.35, 1.0, 1.0)
		2:
			return Color(0.15, 0.65, 0.2, 1.0)
		3:
			return Color(0.9, 0.2, 0.2, 1.0)
		4:
			return Color(0.45, 0.2, 0.85, 1.0)
		5:
			return Color(0.7, 0.2, 0.1, 1.0)
		6:
			return Color(0.1, 0.65, 0.7, 1.0)
		_:
			return Color.BLACK
