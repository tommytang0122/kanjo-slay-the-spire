class_name GridManager
extends Node

signal member_moved(member_index: int, new_pos: Vector2i)

const GRID_SIZE := 9
const TILE_SIZE := 48
const GRID_ORIGIN := Vector2(360, 36)

var positions: Dictionary = {}  # member_index: int -> Vector2i
var alive_members: Array[int] = []  # tracked externally

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

# Cardinal + diagonal neighbors, cardinal first
const ADJACENTS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1),
]

func setup_positions() -> void:
	positions.clear()
	alive_members.clear()
	var center := Vector2i(4, 4)
	for i in TEAM_OFFSETS.size():
		positions[i] = center + TEAM_OFFSETS[i]
		alive_members.append(i)

func mark_dead(member_index: int) -> void:
	alive_members.erase(member_index)

func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

func _is_occupied(pos: Vector2i, exclude: int = -1) -> bool:
	for idx in alive_members:
		if idx == exclude:
			continue
		if positions.get(idx) == pos:
			return true
	return false

func try_move_member(member_index: int, card_type: String) -> bool:
	if card_type not in DIRECTIONS:
		return false
	if member_index not in positions:
		return false
	var dir: Vector2i = DIRECTIONS[card_type]
	var new_pos: Vector2i = positions[member_index] + dir
	if not _is_in_bounds(new_pos):
		return false
	if _is_occupied(new_pos, member_index):
		return false
	positions[member_index] = new_pos
	member_moved.emit(member_index, new_pos)
	return true

# --- Formation: two_pair ---
# Pair 1: Tank(0) + DPS1(2), Pair 2: Healer(1) + DPS2(3)
# Higher-priority member stays, partner moves adjacent.
func execute_two_pair() -> void:
	var occupied: Dictionary = {}  # pos -> member_index (tracks placed members)

	# Place members that stay (Tank=0, Healer=1) first
	for idx in [0, 1]:
		if idx in alive_members:
			occupied[positions[idx]] = idx

	# Move DPS1(2) next to Tank(0)
	_move_adjacent_to(2, 0, occupied)
	# Move DPS2(3) next to Healer(1)
	_move_adjacent_to(3, 1, occupied)

func _move_adjacent_to(mover: int, anchor: int, occupied: Dictionary) -> void:
	if mover not in alive_members or anchor not in alive_members:
		return
	var anchor_pos: Vector2i = positions[anchor]
	for offset in ADJACENTS:
		var candidate := anchor_pos + offset
		if _is_in_bounds(candidate) and candidate not in occupied:
			occupied[candidate] = mover
			# Free old position if it was tracked
			for key in occupied.keys():
				if occupied[key] == mover and key != candidate:
					occupied.erase(key)
			positions[mover] = candidate
			member_moved.emit(mover, candidate)
			return

# --- Formation: four_split ---
# Targets: (7,7), (1,7), (7,1), (1,1). Greedy assignment by priority.
func execute_four_split() -> void:
	var center := Vector2i(4, 4)
	var targets: Array[Vector2i] = [
		center + Vector2i(3, 3),    # (7,7)
		center + Vector2i(-3, 3),   # (1,7)
		center + Vector2i(3, -3),   # (7,1)
		center + Vector2i(-3, -3),  # (1,1)
	]
	var available := targets.duplicate()
	# Priority order: Tank(0) > Healer(1) > DPS1(2) > DPS2(3)
	for idx in [0, 1, 2, 3]:
		if idx not in alive_members:
			continue
		var best_target := Vector2i(-1, -1)
		var best_dist := 999
		for t in available:
			var dist := _manhattan(positions[idx], t)
			if dist < best_dist:
				best_dist = dist
				best_target = t
		if best_target != Vector2i(-1, -1):
			available.erase(best_target)
			positions[idx] = best_target
			member_moved.emit(idx, best_target)

# --- Formation: stack ---
# Others move adjacent to the target member.
func execute_stack(target_index: int) -> void:
	if target_index not in alive_members:
		return
	var target_pos: Vector2i = positions[target_index]
	var occupied: Dictionary = {}
	occupied[target_pos] = target_index

	# Priority order for filling adjacent slots
	for idx in [0, 1, 2, 3]:
		if idx == target_index or idx not in alive_members:
			continue
		var placed := false
		for offset in ADJACENTS:
			var candidate := target_pos + offset
			if _is_in_bounds(candidate) and candidate not in occupied:
				occupied[candidate] = idx
				positions[idx] = candidate
				member_moved.emit(idx, candidate)
				placed = true
				break
		if not placed:
			# No free adjacent cell; stay in place
			pass

func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)

func grid_to_screen(grid_pos: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0, grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0)
