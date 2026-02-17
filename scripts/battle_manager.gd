class_name BattleManager
extends Node

signal card_played(card: CardData)
signal enemy_acted(action: String, damage: int)
signal battle_ended(won: bool)
signal energy_changed(current: int, max_val: int)

const CARDS_PER_TURN := 5
const MAX_ENERGY := 3

var energy: int = 0

@onready var turn_system: TurnSystem = $TurnSystem
@onready var deck_manager: DeckManager = $DeckManager
@onready var grid_manager: GridManager = $GridManager

var player_node: PlayerNode
var enemy_node: EnemyNode
var is_player_turn := false

func setup(player: PlayerNode, enemy: EnemyNode, player_data: CharacterData) -> void:
	player_node = player
	enemy_node = enemy

	deck_manager.setup(player_data.deck)
	player_node.died.connect(_on_player_died)
	enemy_node.died.connect(_on_enemy_died)
	turn_system.phase_changed.connect(_on_phase_changed)

	turn_system.start_battle()

func execute_card(card: CardData) -> void:
	if not is_player_turn:
		return
	if energy < card.cost:
		return
	if card.card_type == "attack":
		energy -= card.cost
		energy_changed.emit(energy, MAX_ENERGY)
		deck_manager.play_card(card)
		enemy_node.take_damage(card.damage)
		card_played.emit(card)
	else:
		if grid_manager.try_move(card.card_type):
			energy -= card.cost
			energy_changed.emit(energy, MAX_ENERGY)
			deck_manager.play_card(card)
			card_played.emit(card)

func end_player_turn() -> void:
	if not is_player_turn:
		return
	is_player_turn = false
	deck_manager.discard_hand()
	turn_system.end_player_turn()

func _on_phase_changed(phase: TurnSystem.Phase) -> void:
	match phase:
		TurnSystem.Phase.PLAYER_START:
			energy = MAX_ENERGY
			energy_changed.emit(energy, MAX_ENERGY)
			deck_manager.draw_cards(CARDS_PER_TURN)
			turn_system.begin_player_turn()
		TurnSystem.Phase.PLAYER_TURN:
			is_player_turn = true
		TurnSystem.Phase.ENEMY_ACTION:
			_execute_enemy_turn()
		TurnSystem.Phase.BATTLE_WON:
			battle_ended.emit(true)
		TurnSystem.Phase.BATTLE_LOST:
			battle_ended.emit(false)

func _execute_enemy_turn() -> void:
	var action := enemy_node.get_current_intent()
	var damage := enemy_node.execute_action()
	if damage > 0:
		player_node.take_damage(damage)
	enemy_acted.emit(action, damage)
	if player_node.current_hp > 0:
		turn_system.begin_next_turn()

func _on_enemy_died() -> void:
	is_player_turn = false
	turn_system.battle_won()

func _on_player_died() -> void:
	is_player_turn = false
	turn_system.battle_lost()
