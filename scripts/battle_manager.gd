class_name BattleManager
extends Node

signal card_played(card: CardData)
signal enemy_acted(action: String, damage: int)
signal battle_ended(won: bool)
signal energy_changed(current: int, max_val: int)

const MAX_ELIXIR := 10
const ELIXIR_REGEN_INTERVAL := 2.0
const INITIAL_ELIXIR := 5

const SHIELD_AMOUNT := 5
const HEAL_AMOUNT := 8
const FINAL_HIT_MULTIPLIER := 2

var elixir: int = 0
var cards_played_count: int = 0

@onready var deck_manager: DeckManager = $DeckManager
@onready var grid_manager: GridManager = $GridManager

var team_members: Array[PlayerNode] = []
var enemy_node: EnemyNode

var _elixir_timer: float = 0.0
var _enemy_timer: float = 0.0
var _enemy_attack_interval: float = 3.0
var _battle_active := false

func setup(members: Array[PlayerNode], enemy: EnemyNode, player_data: CharacterData, enemy_data: CharacterData) -> void:
	team_members = members
	enemy_node = enemy
	_enemy_attack_interval = enemy_data.attack_interval

	deck_manager.setup(player_data.deck)
	for member in team_members:
		member.died.connect(_on_member_died)
	enemy_node.died.connect(_on_enemy_died)

	elixir = INITIAL_ELIXIR
	cards_played_count = 0
	_elixir_timer = 0.0
	_enemy_timer = 0.0
	_battle_active = true
	energy_changed.emit(elixir, MAX_ELIXIR)

func _process(delta: float) -> void:
	if not _battle_active:
		return

	_elixir_timer += delta
	if _elixir_timer >= ELIXIR_REGEN_INTERVAL:
		_elixir_timer -= ELIXIR_REGEN_INTERVAL
		if elixir < MAX_ELIXIR:
			elixir += 1
			energy_changed.emit(elixir, MAX_ELIXIR)

	_enemy_timer += delta
	if _enemy_timer >= _enemy_attack_interval:
		_enemy_timer -= _enemy_attack_interval
		_execute_enemy_attack()

func execute_card(card: CardData, member_index: int = -1) -> void:
	if not _battle_active:
		return
	if elixir < card.cost:
		return

	var card_type := card.card_type
	var is_move := card_type.begins_with("move_")

	# Move cards require a target member
	if is_move and member_index < 0:
		return
	# Check target member is alive for moves
	if is_move and member_index >= 0:
		if member_index >= team_members.size() or not team_members[member_index].is_alive:
			return

	match card_type:
		"attack":
			elixir -= card.cost
			energy_changed.emit(elixir, MAX_ELIXIR)
			deck_manager.play_card(card)
			enemy_node.take_damage(card.damage)
			cards_played_count += 1
			card_played.emit(card)
		"shield_up":
			elixir -= card.cost
			energy_changed.emit(elixir, MAX_ELIXIR)
			deck_manager.play_card(card)
			for member in team_members:
				member.add_shield(SHIELD_AMOUNT)
			cards_played_count += 1
			card_played.emit(card)
		"area_heal":
			elixir -= card.cost
			energy_changed.emit(elixir, MAX_ELIXIR)
			deck_manager.play_card(card)
			for member in team_members:
				member.heal(HEAL_AMOUNT)
			cards_played_count += 1
			card_played.emit(card)
		"final_hit":
			elixir -= card.cost
			energy_changed.emit(elixir, MAX_ELIXIR)
			deck_manager.play_card(card)
			var damage := FINAL_HIT_MULTIPLIER * cards_played_count
			enemy_node.take_damage(damage)
			cards_played_count = 0
			card_played.emit(card)
		_:
			# Move cards
			if is_move:
				if grid_manager.try_move_member(member_index, card_type):
					elixir -= card.cost
					energy_changed.emit(elixir, MAX_ELIXIR)
					deck_manager.play_card(card)
					cards_played_count += 1
					card_played.emit(card)

func _execute_enemy_attack() -> void:
	if not _battle_active:
		return
	var action := enemy_node.get_current_intent()
	var damage := enemy_node.execute_action()
	if damage > 0:
		var alive_members := team_members.filter(func(m: PlayerNode) -> bool: return m.is_alive)
		if alive_members.size() > 0:
			var target: PlayerNode = alive_members.pick_random()
			target.take_damage(damage)
	enemy_acted.emit(action, damage)

func _on_enemy_died() -> void:
	_battle_active = false
	battle_ended.emit(true)

func _on_member_died() -> void:
	var all_dead := true
	for member in team_members:
		if member.is_alive:
			all_dead = false
			break
	if all_dead:
		_battle_active = false
		battle_ended.emit(false)
