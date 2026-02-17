extends Node2D

@onready var player_node: PlayerNode = $PlayerNode
@onready var enemy_node: EnemyNode = $EnemyNode
@onready var battle_manager: BattleManager = $BattleManager
@onready var player_health_bar: HealthBar = $CanvasLayer/PlayerHealthBar
@onready var enemy_health_bar: HealthBar = $CanvasLayer/EnemyHealthBar
@onready var hand_ui: HandUI = $CanvasLayer/HandUI
@onready var end_turn_button: Button = $CanvasLayer/EndTurnButton
@onready var turn_label: Label = $CanvasLayer/TurnLabel
@onready var result_label: Label = $CanvasLayer/ResultLabel

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

	# Connect end turn button
	end_turn_button.pressed.connect(battle_manager.end_player_turn)

	# Connect turn label
	battle_manager.turn_system.phase_changed.connect(_on_phase_changed)

	# Connect battle end
	battle_manager.battle_ended.connect(_on_battle_ended)

	# Connect enemy intent
	enemy_node.intent_changed.connect(_on_intent_changed)

	# Start battle
	battle_manager.setup(player_node, enemy_node, player_data)

func _on_phase_changed(phase: TurnSystem.Phase) -> void:
	turn_label.text = "Turn %d" % battle_manager.turn_system.turn_number
	end_turn_button.disabled = phase != TurnSystem.Phase.PLAYER_TURN

func _on_battle_ended(won: bool) -> void:
	result_label.visible = true
	result_label.text = "VICTORY!" if won else "DEFEAT..."
	end_turn_button.disabled = true

func _on_intent_changed(_intent: String) -> void:
	pass # IntentLabel on EnemyNode handles its own display
