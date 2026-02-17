extends Node2D

@onready var player_node: PlayerNode = $PlayerNode
@onready var enemy_node: EnemyNode = $EnemyNode
@onready var battle_manager: BattleManager = $BattleManager
@onready var player_health_bar: HealthBar = $CanvasLayer/PlayerHealthBar
@onready var enemy_health_bar: HealthBar = $CanvasLayer/EnemyHealthBar
@onready var hand_ui: HandUI = $CanvasLayer/HandUI
@onready var result_label: Label = $CanvasLayer/ResultLabel
@onready var energy_label: Label = $CanvasLayer/EnergyLabel
@onready var battle_grid: BattleGrid = $BattleGrid

var player_data: CharacterData = preload("res://data/characters/player.tres")
var enemy_data: CharacterData = preload("res://data/characters/slime.tres")

func _ready() -> void:
	result_label.visible = false

	# Connect HP bars before setup so initial hp_changed signals are received
	player_node.hp_changed.connect(player_health_bar.update_hp)
	enemy_node.hp_changed.connect(enemy_health_bar.update_hp)

	player_node.setup(player_data)
	enemy_node.setup(enemy_data)

	# Connect hand UI
	battle_manager.deck_manager.hand_updated.connect(hand_ui.update_hand)
	hand_ui.card_selected.connect(battle_manager.execute_card)

	# Connect energy
	battle_manager.energy_changed.connect(_on_energy_changed)
	battle_manager.energy_changed.connect(hand_ui.update_energy)

	# Connect battle end
	battle_manager.battle_ended.connect(_on_battle_ended)

	# Connect enemy intent
	enemy_node.intent_changed.connect(_on_intent_changed)

	# Setup grid — player on left grid, enemy fixed on right
	var gm := battle_manager.grid_manager
	player_node.position = gm.grid_to_screen(gm.player_pos)
	enemy_node.position = Vector2(900, 300)
	battle_grid.update_position(gm.player_pos)
	gm.player_moved.connect(_on_player_moved)

	# Start battle
	battle_manager.setup(player_node, enemy_node, player_data, enemy_data)

func _on_battle_ended(won: bool) -> void:
	result_label.visible = true
	result_label.text = "VICTORY!" if won else "DEFEAT..."

func _on_player_moved(new_pos: Vector2i) -> void:
	var gm := battle_manager.grid_manager
	player_node.position = gm.grid_to_screen(new_pos)
	battle_grid.update_position(new_pos)

func _on_energy_changed(current: int, max_val: int) -> void:
	energy_label.text = "Elixir: %d / %d" % [current, max_val]

func _on_intent_changed(_intent: String) -> void:
	pass # IntentLabel on EnemyNode handles its own display
