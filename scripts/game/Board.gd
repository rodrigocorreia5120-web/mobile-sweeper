extends Node2D

signal mode_changed(mode: String)
signal game_won
signal game_lost
signal status_changed(text: String)
signal counters_changed(total_bombs: int, flags_left: int)

const HEX_CELL_SCENE := preload("res://scenes/game/HexCell.tscn")

@export var grid_radius: int = 3
@export var hex_width: float = 72.0
@export var hex_height: float = 64.0

# Feinsteuerung für Abstände
@export var horizontal_spacing_factor: float = 0.665
@export var vertical_spacing_factor: float = 0.7525

# Zusätzlicher globaler Offset nach dem Zentrieren
@export var board_offset: Vector2 = Vector2(0, 40)

# Bildschirm-Mittelpunkt, an dem das Board zentriert werden soll
@export var board_anchor: Vector2 = Vector2(400, 360)

@export var bomb_count: int = 6

var cells: Dictionary = {}
var game_over: bool = false
var first_click_done: bool = false
var current_mode: String = "reveal"

const AXIAL_DIRECTIONS := [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

func _ready() -> void:
	start_new_game()

func start_new_game() -> void:
	game_over = false
	first_click_done = false
	current_mode = "reveal"

	_clear_existing_cells()
	_create_hex_grid()
	_center_board()
	_place_bombs()
	_calculate_neighbor_counts()

	mode_changed.emit(current_mode)
	status_changed.emit("")
	_emit_counter_update()

func set_mode(new_mode: String) -> void:
	if new_mode != "reveal" and new_mode != "flag":
		return

	current_mode = new_mode
	mode_changed.emit(current_mode)

func _clear_existing_cells() -> void:
	for key in cells.keys():
		cells[key].queue_free()
	cells.clear()

func _create_hex_grid() -> void:
	for q in range(-grid_radius, grid_radius + 1):
		for r in range(-grid_radius, grid_radius + 1):
			var s = -q - r
			if abs(s) > grid_radius:
				continue

			var cell = HEX_CELL_SCENE.instantiate()
			add_child(cell)

			cell.setup(q, r)
			cell.position = _axial_to_pixel(q, r)
			cell.cell_pressed.connect(_on_cell_pressed)

			cells[Vector2i(q, r)] = cell

func _center_board() -> void:
	if cells.is_empty():
		return

	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF

	for pos in cells.keys():
		var cell = cells[pos]
		min_x = min(min_x, cell.position.x)
		max_x = max(max_x, cell.position.x)
		min_y = min(min_y, cell.position.y)
		max_y = max(max_y, cell.position.y)

	var board_center = Vector2(
		(min_x + max_x) * 0.5,
		(min_y + max_y) * 0.5
	)

	var shift = board_anchor - board_center + board_offset

	for pos in cells.keys():
		var cell = cells[pos]
		cell.position += shift

func _place_bombs() -> void:
	var all_positions = cells.keys()
	all_positions.shuffle()

	for i in range(min(bomb_count, all_positions.size())):
		var pos = all_positions[i]
		cells[pos].is_bomb = true

func _calculate_neighbor_counts() -> void:
	for pos in cells.keys():
		var cell = cells[pos]

		if cell.is_bomb:
			cell.neighbor_bombs = 0
			continue

		var count := 0
		for dir in AXIAL_DIRECTIONS:
			var neighbor_pos = pos + dir
			if cells.has(neighbor_pos) and cells[neighbor_pos].is_bomb:
				count += 1

		cell.neighbor_bombs = count

func _on_cell_pressed(cell) -> void:
	if game_over:
		return

	if current_mode == "flag":
		if not cell.is_revealed:
			cell.toggle_flag()
			_emit_counter_update()
		return

	if cell.is_revealed or cell.is_flagged:
		return

	if not first_click_done:
		first_click_done = true
		_ensure_safe_first_click(cell)

	if cell.is_bomb:
		cell.reveal()
		_reveal_all_bombs()
		_mark_wrong_flags()
		game_over = true
		status_changed.emit("Game Over")
		game_lost.emit()
		_emit_counter_update()
		return

	if cell.neighbor_bombs == 0:
		_flood_fill(cell)
	else:
		cell.reveal()

	if _check_win():
		game_over = true
		status_changed.emit("You Win")
		game_won.emit()

	_emit_counter_update()

func _ensure_safe_first_click(clicked_cell) -> void:
	if not clicked_cell.is_bomb:
		return

	var target_cell = null

	for pos in cells.keys():
		var candidate = cells[pos]
		if candidate == clicked_cell:
			continue
		if candidate.is_bomb:
			continue
		if candidate.is_revealed:
			continue
		target_cell = candidate
		break

	if target_cell == null:
		return

	clicked_cell.is_bomb = false
	target_cell.is_bomb = true
	_calculate_neighbor_counts()

func _flood_fill(start_cell) -> void:
	var queue: Array = [start_cell]

	while queue.size() > 0:
		var current = queue.pop_front()

		if current.is_revealed or current.is_flagged:
			continue

		current.reveal()

		if current.neighbor_bombs != 0:
			continue

		for dir in AXIAL_DIRECTIONS:
			var neighbor_pos = Vector2i(current.q, current.r) + dir
			if cells.has(neighbor_pos):
				var neighbor = cells[neighbor_pos]

				if not neighbor.is_revealed and not neighbor.is_bomb and not neighbor.is_flagged:
					if not queue.has(neighbor):
						queue.append(neighbor)

func _reveal_all_bombs() -> void:
	for pos in cells.keys():
		var cell = cells[pos]
		cell.force_show_bomb()

func _mark_wrong_flags() -> void:
	for pos in cells.keys():
		var cell = cells[pos]
		cell.mark_wrong_flag()

func _check_win() -> bool:
	for pos in cells.keys():
		var cell = cells[pos]
		if not cell.is_bomb and not cell.is_revealed:
			return false
	return true

func _count_flags() -> int:
	var count := 0
	for pos in cells.keys():
		var cell = cells[pos]
		if cell.is_flagged:
			count += 1
	return count

func _emit_counter_update() -> void:
	var flags_left = bomb_count - _count_flags()
	counters_changed.emit(bomb_count, flags_left)

func _axial_to_pixel(q: int, r: int) -> Vector2:
	var x = hex_width * horizontal_spacing_factor * q
	var y = hex_height * vertical_spacing_factor * (r + q / 2.0)
	return Vector2(x, y)
