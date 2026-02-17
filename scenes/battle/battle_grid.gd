class_name BattleGrid
extends Node2D

const GRID_SIZE := 9
const TILE_SIZE := 48

var player_pos := Vector2i(4, 4)

func update_position(p_player_pos: Vector2i) -> void:
	player_pos = p_player_pos
	queue_redraw()

func _draw() -> void:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var pos := Vector2i(x, y)
			if pos == player_pos:
				draw_rect(rect, Color(0.3, 0.5, 0.9, 0.6))
			else:
				draw_rect(rect, Color(0.25, 0.25, 0.3, 0.4))
			draw_rect(rect, Color(0.5, 0.5, 0.5, 0.3), false)
