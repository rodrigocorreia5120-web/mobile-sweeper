extends Node2D

const COLOR_BACKGROUND := Color("#4A2A47")

@onready var board = $Board
@onready var hud = $HUD

func _ready() -> void:
	RenderingServer.set_default_clear_color(COLOR_BACKGROUND)

	if not hud.reveal_requested.is_connected(_on_reveal_requested):
		hud.reveal_requested.connect(_on_reveal_requested)

	if not hud.flag_requested.is_connected(_on_flag_requested):
		hud.flag_requested.connect(_on_flag_requested)

	if not hud.restart_requested.is_connected(_on_restart_requested):
		hud.restart_requested.connect(_on_restart_requested)

	if not board.mode_changed.is_connected(_on_board_mode_changed):
		board.mode_changed.connect(_on_board_mode_changed)

	if not board.status_changed.is_connected(_on_board_status_changed):
		board.status_changed.connect(_on_board_status_changed)

	if not board.counters_changed.is_connected(_on_board_counters_changed):
		board.counters_changed.connect(_on_board_counters_changed)

	hud.set_mode(board.current_mode)
	hud.set_status("")
	hud.set_counters(board.bomb_count, board.bomb_count)

func _on_reveal_requested() -> void:
	board.set_mode("reveal")

func _on_flag_requested() -> void:
	board.set_mode("flag")

func _on_restart_requested() -> void:
	board.start_new_game()

func _on_board_mode_changed(mode: String) -> void:
	hud.set_mode(mode)

func _on_board_status_changed(text: String) -> void:
	hud.set_status(text)

func _on_board_counters_changed(total_bombs: int, flags_left: int) -> void:
	hud.set_counters(total_bombs, flags_left)
