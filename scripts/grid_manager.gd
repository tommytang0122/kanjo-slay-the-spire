class_name GridManager
extends Node

signal member_moved(member_index: int, new_pos: Vector2i)

const GRID_SIZE := 9
const TILE_SIZE := 48
const GRID_ORIGIN := Vector2(360, 36)

var positions: Dictionary = {}  # member_index: int -> Vector2i

const DIRECTIONS := {
	"move_up": Vector2i(0, -1),
	"move_down": Vector2i(0, 1),
	"move_left": Vector2i(-1, 0),
	"move_right": Vector2i(1, 0),
}

const TEAM_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),   # Tank: right of center
	Vector2i(0, 1),   # Healer: below center
	Vector2i(-1, 0),  # DPS1: left of center
	Vector2i(0, -1),  # DPS2: above center
]

func setup_positions() -> void:
	positions.clear()
	var center := Vector2i(4, 4)
	for i in TEAM_OFFSETS.size():
		positions[i] = center + TEAM_OFFSETS[i]

func try_move_member(member_index: int, card_type: String) -> bool:
	if card_type not in DIRECTIONS:
		return false
	if member_index not in positions:
		return false
	var dir: Vector2i = DIRECTIONS[card_type]
	var new_pos: Vector2i = positions[member_index] + dir
	if new_pos.x < 0 or new_pos.x >= GRID_SIZE or new_pos.y < 0 or new_pos.y >= GRID_SIZE:
		return false
	positions[member_index] = new_pos
	member_moved.emit(member_index, new_pos)
	return true

func grid_to_screen(grid_pos: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0, grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0)
