extends Node
class_name PlayerStats

# ============================================================
# SIGNALS
# ============================================================
signal hp_changed(current_hp: int, max_hp: int)
signal xp_changed(current_xp: int, xp_needed: int, current_level: int)
signal coins_changed(coins: int)
signal inventory_changed
signal boosts_changed            # opsional: update window status
signal damage_changed(new_damage: int)

# ============================================================
# ATRIBUT (GDD)
# ============================================================
var hp_max: int = 100
var hp_current: int = 100
var xp: int = 0
var level: int = 1
var damage: int = 10

# ============================================================
# PENGATURAN LEVEL
# ============================================================
const XP_PER_LEVEL: int = 30
const MAX_LEVEL: int = 5

# ============================================================
# INVENTORY & COINS
# ============================================================
const ITEM_DIR := "res://data/items/"

var coins: int = 0
var inventory: Dictionary = {}   # id -> jumlah

# ============================================================
# BOOSTER PERMANEN
# ============================================================
# Asah Besi : +5 Damage per stack (maks 2x)
# Berkat Kabut : +30 Max HP per stack (maks 3x)
var boosts: Dictionary = {"asah_besi": 0, "berkat_kabut": 0}
const BOOST_MAX: Dictionary = {"asah_besi": 2, "berkat_kabut": 3}
const BOOST_INFO := {
	"asah_besi": {"name": "Asah Besi", "stat": "Damage", "per": 5,
		"icon": "res://assets/icons/items/booster_asah_besi.png"},
	"berkat_kabut": {"name": "Berkat Kabut", "stat": "Max HP", "per": 30,
		"icon": "res://assets/icons/items/booster_berkat_kabut.png"},
}


# Terpakai + masih tersimpan di inventory (dipakai toko untuk membatasi tukar)
func boost_total(boost_id: String) -> int:
	return boosts.get(boost_id, 0) + get_count(StringName(boost_id))
	
# ============================================================
# STATE UI
# ============================================================
var ui_open: bool = false   # true saat window status/toko terbuka (hero berhenti)

# ============================================================
# READY
# ============================================================
func _ready() -> void:
	hp_current = hp_max
	hp_changed.emit(hp_current, hp_max)
	xp_changed.emit(xp, XP_PER_LEVEL, level)
	coins_changed.emit(coins)

# ============================================================
# HP & COMBAT
# ============================================================
func take_damage(amount: int) -> void:
	hp_current = clamp(hp_current - amount, 0, hp_max)
	hp_changed.emit(hp_current, hp_max)

func heal(amount: int) -> void:
	hp_current = clamp(hp_current + amount, 0, hp_max)
	hp_changed.emit(hp_current, hp_max)

# ============================================================
# XP & LEVEL
# ============================================================
func add_xp(amount: int) -> void:
	if level >= MAX_LEVEL:
		return
	xp += amount
	while xp >= XP_PER_LEVEL and level < MAX_LEVEL:
		xp -= XP_PER_LEVEL
		level += 1
		hp_max += 10
		damage += 2
		hp_current = hp_max
		hp_changed.emit(hp_current, hp_max)
		damage_changed.emit(damage)
		print("Naik ke Level ", level, "! Max HP: ", hp_max, ", Damage: ", damage)
	xp_changed.emit(xp, XP_PER_LEVEL, level)

# ============================================================
# COINS
# ============================================================
func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true

# ============================================================
# INVENTORY
# ============================================================
func get_item_data(id: StringName) -> ItemData:
	var path := ITEM_DIR + String(id) + ".tres"
	return load(path) if ResourceLoader.exists(path) else null

func get_count(id: StringName) -> int:
	return inventory.get(id, 0)

func add_item(id: StringName, amount: int = 1) -> void:
	inventory[id] = get_count(id) + amount
	inventory_changed.emit()

func remove_item(id: StringName, amount: int = 1) -> bool:
	if get_count(id) < amount:
		return false
	inventory[id] -= amount
	if inventory[id] <= 0:
		inventory.erase(id)
	inventory_changed.emit()
	return true

func sell_item(id: StringName) -> bool:
	var data := get_item_data(id)
	if data == null or data.sell_price <= 0:
		return false
	if not remove_item(id):
		return false
	add_coins(data.sell_price)
	return true

# ============================================================
# USE ITEM
# ============================================================
func use_item(id: StringName) -> bool:
	var data := get_item_data(id)
	if data == null or get_count(id) <= 0:
		return false

	match data.type:
		ItemData.Type.CONSUMABLE:
			if data.heal_amount <= 0 or hp_current >= hp_max:
				return false
			remove_item(id)
			heal(data.heal_amount)
			return true
		ItemData.Type.BOOSTER:
			if not apply_boost(data.boost_id):
				return false   # sudah mencapai batas
			remove_item(id)
			return true
	return false

# ============================================================
# BOOSTER PERMANEN
# ============================================================
func apply_boost(boost_id: String) -> bool:
	# tolak kalau id tidak dikenal
	if not boosts.has(boost_id):
		return false

	# tolak kalau sudah maksimal
	var max_stack: int = BOOST_MAX.get(boost_id, 0)
	if boosts[boost_id] >= max_stack:
		return false

	# increment stack & apply efek
	boosts[boost_id] += 1
	match boost_id:
		"asah_besi":
			damage += 5
			damage_changed.emit(damage)
		"berkat_kabut":
			hp_max += 30
			hp_current += 30
			hp_changed.emit(hp_current, hp_max)

	boosts_changed.emit()
	return true

# ============================================================
# HELPER (dipakai window status)
# ============================================================
func get_boost_count(boost_id: String) -> int:
	return boosts.get(boost_id, 0)

func is_boost_maxed(boost_id: String) -> bool:
	return get_boost_count(boost_id) >= BOOST_MAX.get(boost_id, 0)
