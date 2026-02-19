extends Node2D

@onready var enemy_node: EnemyNode = $EnemyNode
@onready var battle_manager: BattleManager = $BattleManager
@onready var enemy_health_bar: HealthBar = $CanvasLayer/EnemyHealthBar
@onready var hand_ui: HandUI = $CanvasLayer/HandUI
@onready var result_label: Label = $CanvasLayer/ResultLabel
@onready var energy_label: Label = $CanvasLayer/EnergyLabel
@onready var battle_grid: BattleGrid = $BattleGrid
@onready var team_panel: TeamPanel = $CanvasLayer/TeamPanel
@onready var battlefield_drop: BattlefieldDrop = $CanvasLayer/BattlefieldDrop
@onready var cards_played_label: Label = $CanvasLayer/CardsPlayedLabel

var player_data: CharacterData = preload("res://data/characters/player.tres")
var enemy_data: CharacterData = preload("res://data/characters/slime.tres")

var team_data: Array[CharacterData] = [
	preload("res://data/characters/team_tank.tres"),
	preload("res://data/characters/team_healer.tres"),
	preload("res://data/characters/team_dps1.tres"),
	preload("res://data/characters/team_dps2.tres"),
]

var team_nodes: Array[PlayerNode] = []

func _ready() -> void:
	result_label.visible = false

	# Get team member nodes
	team_nodes = [
		$TeamMember0 as PlayerNode,
		$TeamMember1 as PlayerNode,
		$TeamMember2 as PlayerNode,
		$TeamMember3 as PlayerNode,
	]

	# Setup team panel
	team_panel.setup_members(team_data)

	# Setup each team member
	var gm := battle_manager.grid_manager
	gm.setup_positions()

	for i in team_nodes.size():
		var member := team_nodes[i]
		member.member_index = i

		# Connect HP/shield signals to team panel
		member.hp_changed.connect(func(cur: int, max_val: int) -> void:
			team_panel.update_member_hp(i, cur, max_val)
		)
		member.shield_changed.connect(func(shield: int) -> void:
			team_panel.update_member_shield(i, shield)
		)
		member.died.connect(func() -> void:
			member.visible = false
			battle_grid.remove_member(i)
		)

		# Setup with character data
		member.setup(team_data[i])

		# Position on grid
		member.position = gm.grid_to_screen(gm.positions[i])
		battle_grid.update_member_position(i, gm.positions[i])

	# Connect enemy HP
	enemy_node.hp_changed.connect(enemy_health_bar.update_hp)
	enemy_node.setup(enemy_data)
	enemy_node.position = Vector2(900, 300)

	# Connect hand UI
	battle_manager.deck_manager.hand_updated.connect(hand_ui.update_hand)

	# Connect drag-and-drop: battlefield drop
	battlefield_drop.card_played_on_field.connect(func(card: CardData) -> void:
		battle_manager.execute_card(card, -1)
	)

	# Connect drag-and-drop: team panel member drop
	team_panel.card_dropped_on_member.connect(func(card: CardData, member_index: int) -> void:
		battle_manager.execute_card(card, member_index)
	)

	# Connect energy
	battle_manager.energy_changed.connect(_on_energy_changed)
	battle_manager.energy_changed.connect(hand_ui.update_energy)

	# Connect battle end
	battle_manager.battle_ended.connect(_on_battle_ended)

	# Connect card played to update N counter
	battle_manager.card_played.connect(_on_card_played)

	# Connect grid movement
	gm.member_moved.connect(_on_member_moved)

	# Start battle
	battle_manager.setup(team_nodes, enemy_node, player_data, enemy_data)
	_update_cards_played_label()

func _on_battle_ended(won: bool) -> void:
	result_label.visible = true
	result_label.text = "VICTORY!" if won else "DEFEAT..."

func _on_member_moved(member_index: int, new_pos: Vector2i) -> void:
	var gm := battle_manager.grid_manager
	team_nodes[member_index].position = gm.grid_to_screen(new_pos)
	battle_grid.update_member_position(member_index, new_pos)

func _on_energy_changed(current: int, max_val: int) -> void:
	energy_label.text = "Elixir: %d / %d" % [current, max_val]

func _on_card_played(_card: CardData) -> void:
	_update_cards_played_label()

func _update_cards_played_label() -> void:
	cards_played_label.text = "N: %d" % battle_manager.cards_played_count
