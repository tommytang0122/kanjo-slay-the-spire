class_name GridManager
extends Node

signal player_moved(new_pos: Vector2i)

const GRID_SIZE := 9
const TILE_SIZE := 48
const GRID_ORIGIN := Vector2(360, 36)

var player_pos := Vector2i(4, 4)

const DIRECTIONS := {
	"move_up": Vector2i(0, -1),
	"move_down": Vector2i(0, 1),
	"move_left": Vector2i(-1, 0),
	"move_right": Vector2i(1, 0),
}

func try_move(card_type: String) -> bool:
	if card_type not in DIRECTIONS:
		return false
	var dir: Vector2i = DIRECTIONS[card_type]
	var new_pos: Vector2i = player_pos + dir
	if new_pos.x < 0 or new_pos.x >= GRID_SIZE or new_pos.y < 0 or new_pos.y >= GRID_SIZE:
		return false
	player_pos = new_pos
	player_moved.emit(player_pos)
	return true

func grid_to_screen(grid_pos: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0, grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0)
