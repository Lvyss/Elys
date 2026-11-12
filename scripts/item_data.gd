class_name ItemData
extends Resource

enum Type { COLLECTIBLE, CONSUMABLE, QUEST, BOOSTER }

@export var boost_id: String = ""
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var type: Type = Type.COLLECTIBLE
@export var sell_price: int = 0
@export var heal_amount: int = 0
