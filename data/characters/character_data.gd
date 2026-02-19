class_name CharacterData
extends Resource

@export var character_name: String = ""
@export var max_hp: int = 1
@export var deck: Array[CardData] = []
@export var role: String = ""  # "tank", "healer", "dps1", "dps2", "" for enemies
@export var attack_interval: float = 3.0
