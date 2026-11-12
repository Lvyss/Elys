extends CanvasLayer

enum Mode { SELL, TRADE, BUY }

const ICON_DIR := "res://assets/icons/items/"
const COL_ON := Color("#e8dcc0")
const COL_OFF := Color("#7d7060")
const ACTION_TEXT := ["Jual", "Tukar", "Beli"]

# Tukar: 3 Taring -> Ramuan Taring, 2 Lempeng -> Asah Besi, 1 Kristal -> Berkat Kabut
const RECIPES := [
	{"key": &"ramuan_taring", "name": "Ramuan Taring", "icon": "ramuan_taring",
		"cost": {&"taring_goblin": 3}, "boost": "",
		"desc": "Memulihkan 40 HP. Dipakai dengan tombol Q."},
	{"key": &"asah_besi", "name": "Asah Besi", "icon": "booster_asah_besi",
		"cost": {&"lempeng_besi": 2}, "boost": "asah_besi",
		"desc": "Dipakai dari Inventory: +5 Damage permanen."},
	{"key": &"berkat_kabut", "name": "Berkat Kabut", "icon": "booster_berkat_kabut",
		"cost": {&"kristal_kabut": 1}, "boost": "berkat_kabut",
		"desc": "Dipakai dari Inventory: +30 Max HP permanen."},
]

# Beli dengan koin
const BUYS := [
	{"key": &"ramuan_hijau", "price": 20},
	{"key": &"gulungan_petunjuk", "price": 30},
]

@onready var name_label: Label = %NameLabel
@onready var dialog_label: Label = %DialogLabel
@onready var btn_sell: Button = %BtnSell
@onready var btn_trade: Button = %BtnTrade
@onready var btn_buy: Button = %BtnBuy
@onready var coin_label: Label = %CoinLabel
@onready var title_label: Label = %TitleLabel
@onready var item_list: ItemList = %ItemList
@onready var desc_label: Label = %DescLabel
@onready var action_btn: Button = %ActionBtn
@onready var close_btn: Button = %CloseBtn

var mode := Mode.SELL
var _entries: Array = []
var _sel_key: StringName = &""


func _ready() -> void:
	add_to_group("shop")
	visible = false
	title_label.text = "TOKO ORRIN"

	var group := ButtonGroup.new()
	for b in [btn_sell, btn_trade, btn_buy]:
		b.toggle_mode = true
		b.button_group = group
	btn_sell.pressed.connect(_set_mode.bind(Mode.SELL))
	btn_trade.pressed.connect(_set_mode.bind(Mode.TRADE))
	btn_buy.pressed.connect(_set_mode.bind(Mode.BUY))

	item_list.item_selected.connect(_on_selected)
	action_btn.pressed.connect(_on_action)
	close_btn.pressed.connect(close)

	GameState.coins_changed.connect(func(_c): _on_state_changed())
	GameState.inventory_changed.connect(_on_state_changed)


func open() -> void:
	visible = true
	GameState.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialog_label.text = "Selamat datang, Pengelana. Mau jual, tukar, atau beli?"
	btn_sell.button_pressed = true
	_set_mode(Mode.SELL)


func close() -> void:
	visible = false
	GameState.ui_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
		close()
		get_viewport().set_input_as_handled()


func _on_state_changed() -> void:
	if visible:
		_rebuild()


func _set_mode(m: Mode) -> void:
	mode = m
	_sel_key = &""
	_rebuild()


# ---------------- DAFTAR ----------------
func _rebuild() -> void:
	coin_label.text = "%d" % GameState.coins
	var keep := _sel_key
	_sel_key = &""
	item_list.clear()
	_entries.clear()
	action_btn.visible = false

	match mode:
		Mode.SELL: _build_sell()
		Mode.TRADE: _build_trade()
		Mode.BUY: _build_buy()

	if _entries.is_empty():
		desc_label.text = "Tidak ada barang untuk dijual."
		return
	desc_label.text = "Pilih barang."
	for i in _entries.size():
		if _entries[i].key == keep:
			item_list.select(i)
			_on_selected(i)
			return


func _add_entry(e: Dictionary) -> void:
	var idx := item_list.add_item(e.label, e.icon)
	item_list.set_item_custom_fg_color(idx, COL_ON if e.enabled else COL_OFF)
	_entries.append(e)


func _build_sell() -> void:
	for id in GameState.inventory:
		var data := GameState.get_item_data(id)
		if data == null or data.sell_price <= 0:
			continue
		_add_entry({
			"key": id, "icon": data.icon, "enabled": true,
			"label": "%s x%d   %d koin" % [data.display_name, GameState.get_count(id), data.sell_price],
			"desc": "%s\nHarga jual: %d koin" % [data.description, data.sell_price],
		})


func _build_trade() -> void:
	for r in RECIPES:
		var boost: String = r.boost
		var total: int = GameState.boost_total(boost) if boost != "" else 0
		var limit: int = GameState.BOOST_MAX.get(boost, 0)
		var maxed: bool = boost != "" and total >= limit
		var ok: bool = _has(r.cost) and not maxed
		var label: String = "%s   (%s)" % [r.name, _cost_text(r.cost)]
		var desc: String = "%s\nBahan: %s" % [r.desc, _cost_text(r.cost)]
		if boost != "":
			label += "  %d/%d" % [total, limit]
			if maxed:
				desc += "\nBatas tukar tercapai."
		_add_entry({
			"key": r.key, "icon": _icon(r.icon), "enabled": ok,
			"label": label, "desc": desc, "recipe": r,
		})


func _build_buy() -> void:
	for b in BUYS:
		var data := GameState.get_item_data(b.key)
		if data == null:
			continue
		_add_entry({
			"key": b.key, "icon": data.icon, "enabled": GameState.coins >= b.price,
			"label": "%s   %d koin" % [data.display_name, b.price],
			"desc": "%s\nHarga: %d koin" % [data.description, b.price],
			"price": b.price,
		})


# ---------------- PILIH & AKSI ----------------
func _on_selected(index: int) -> void:
	var e: Dictionary = _entries[index]
	_sel_key = e.key
	desc_label.text = e.desc
	action_btn.text = ACTION_TEXT[mode]
	action_btn.visible = true
	action_btn.disabled = not e.enabled


func _on_action() -> void:
	var idx := item_list.get_selected_items()
	if idx.is_empty():
		return
	var e: Dictionary = _entries[idx[0]]
	if not e.enabled:
		return

	match mode:
		Mode.SELL:
			if GameState.sell_item(e.key):
				dialog_label.text = "Terima kasih. Barang bagus."
		Mode.TRADE:
			_do_trade(e.recipe)
		Mode.BUY:
			if GameState.spend_coins(e.price):
				GameState.add_item(e.key)
				dialog_label.text = "Selamat memakainya."


func _do_trade(r: Dictionary) -> void:
	if not _has(r.cost):
		return
	for id in r.cost:
		GameState.remove_item(id, r.cost[id])
	GameState.add_item(r.key)
	dialog_label.text = "Selesai. Simpan baik-baik, pakai kalau sudah siap."

# ---------------- BANTUAN ----------------
func _has(cost: Dictionary) -> bool:
	for id in cost:
		if GameState.get_count(id) < cost[id]:
			return false
	return true


func _cost_text(cost: Dictionary) -> String:
	var parts: PackedStringArray = []
	for id in cost:
		var d := GameState.get_item_data(id)
		parts.append("%d %s" % [cost[id], d.display_name if d else str(id)])
	return ", ".join(parts)


func _icon(file: String) -> Texture2D:
	var path := ICON_DIR + file + ".png"
	return load(path) if ResourceLoader.exists(path) else null
