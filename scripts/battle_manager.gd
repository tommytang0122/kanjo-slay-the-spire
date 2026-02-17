class_name BattleManager
extends Node

signal card_played(card: CardData)
signal enemy_acted(action: String, damage: int)
signal battle_ended(won: bool)
signal energy_changed(current: int, max_val: int)

const MAX_ELIXIR := 10
const ELIXIR_REGEN_INTERVAL := 2.0
const INITIAL_ELIXIR := 5

var elixir: int = 0

@onready var deck_manager: DeckManager = $DeckManager
@onready var grid_manager: GridManager = $GridManager

var player_node: PlayerNode
var enemy_node: EnemyNode

var _elixir_timer: float = 0.0
var _enemy_timer: float = 0.0
var _enemy_attack_interval: float = 3.0
var _battle_active := false

func setup(player: PlayerNode, enemy: EnemyNode, player_data: CharacterData, enemy_data: CharacterData) -> void:
	player_node = player
	enemy_node = enemy
	_enemy_attack_interval = enemy_data.attack_interval

	deck_manager.setup(player_data.deck)
	player_node.died.connect(_on_player_died)
	enemy_node.died.connect(_on_enemy_died)

	elixir = INITIAL_ELIXIR
	_elixir_timer = 0.0
	_enemy_timer = 0.0
	_battle_active = true
	energy_changed.emit(elixir, MAX_ELIXIR)

func _process(delta: float) -> void:
	if not _battle_active:
		return

	# Elixir regen
	_elixir_timer += delta
	if _elixir_timer >= ELIXIR_REGEN_INTERVAL:
		_elixir_timer -= ELIXIR_REGEN_INTERVAL
		if elixir < MAX_ELIXIR:
			elixir += 1
			energy_changed.emit(elixir, MAX_ELIXIR)

	# Enemy attack timer
	_enemy_timer += delta
	if _enemy_timer >= _enemy_attack_interval:
		_enemy_timer -= _enemy_attack_interval
		_execute_enemy_attack()

func execute_card(card: CardData) -> void:
	if not _battle_active:
		return
	if elixir < card.cost:
		return
	if card.card_type == "attack":
		elixir -= card.cost
		energy_changed.emit(elixir, MAX_ELIXIR)
		deck_manager.play_card(card)
		enemy_node.take_damage(card.damage)
		card_played.emit(card)
	else:
		if grid_manager.try_move(card.card_type):
			elixir -= card.cost
			energy_changed.emit(elixir, MAX_ELIXIR)
			deck_manager.play_card(card)
			card_played.emit(card)

func _execute_enemy_attack() -> void:
	if not _battle_active:
		return
	var action := enemy_node.get_current_intent()
	var damage := enemy_node.execute_action()
	if damage > 0:
		player_node.take_damage(damage)
	enemy_acted.emit(action, damage)

func _on_enemy_died() -> void:
	_battle_active = false
	battle_ended.emit(true)

func _on_player_died() -> void:
	_battle_active = false
	battle_ended.emit(false)
