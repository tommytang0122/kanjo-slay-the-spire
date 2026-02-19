class_name BattleGrid
extends Node2D

const GRID_SIZE := 9
const TILE_SIZE := 48

var member_positions: Dictionary = {}  # index -> Vector2i
var member_colors := [
	Color(0.2, 0.4, 0.8, 0.6),  # Tank: blue
	Color(0.2, 0.8, 0.3, 0.6),  # Healer: green
	Color(0.8, 0.6, 0.2, 0.6),  # DPS1: orange
	Color(0.7, 0.2, 0.7, 0.6),  # DPS2: purple
]

func update_member_position(member_index: int, pos: Vector2i) -> void:
	member_positions[member_index] = pos
	queue_redraw()

func remove_member(member_index: int) -> void:
	member_positions.erase(member_index)
	queue_redraw()

func _draw() -> void:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var pos := Vector2i(x, y)
			var is_member := false
			for idx in member_positions:
				if member_positions[idx] == pos and idx < member_colors.size():
					draw_rect(rect, member_colors[idx])
					is_member = true
					break
			if not is_member:
				draw_rect(rect, Color(0.25, 0.25, 0.3, 0.4))
			draw_rect(rect, Color(0.5, 0.5, 0.5, 0.3), false)
