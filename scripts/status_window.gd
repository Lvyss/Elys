extends CanvasLayer

const TEXT_DARK := Color("#3b2a1e")

const STAT_ICONS := {
	"level": preload("res://assets/icons/stats/icon_xp.png"),
	"hp": preload("res://assets/icons/stats/icon_hp.png"),
	"damage": preload("res://assets/icons/stats/icon_damage.png"),
	"coins": preload("res://assets/icons/stats/icon_koin.png"),
}

@onready var portrait: AnimatedSprite2D = %Portrait
@onready var stats_box: VBoxContainer = %StatsBox
@onready var title_label: Label = %TitleLabel
@onready var item_list: ItemList = %ItemList
@onready var desc_label: Label = %DescLabel
@onready var use_btn: Button = %UseBtn
@onready var close_btn: Button = %CloseBtn
@onready var buff_box: VBoxContainer = %BuffBox

var _selected_id: StringName = &""


func _ready() -> void:
	visible = false
	title_label.text = "INVENTORY"
	close_btn.pressed.connect(close)
	use_btn.pressed.connect(_on_use_pressed)
	item_list.item_selected.connect(_on_item_selected)

	GameState.hp_changed.connect(func(_a, _b): _refresh_if_open())
	GameState.xp_changed.connect(func(_a, _b, _c): _refresh_if_open())
	GameState.coins_changed.connect(func(_c): _refresh_if_open())
	GameState.inventory_changed.connect(_refresh_if_open)
	_connect_hud.call_deferred()

func _connect_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud == null:
		push_warning("HUD tidak ditemukan, tombol profil tidak tersambung")
		return
	hud.profile_pressed.connect(toggle)
	
func toggle() -> void:
	if visible:
		close()
	else:
		open()


func open() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_setup_portrait()
	_refresh()


func close() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Esc menutup window ini dulu, bukan membuka pause
	if visible and event.is_action_pressed("pause"):
		close()
		get_viewport().set_input_as_handled()


func _setup_portrait() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.get("sprite") == null:
		return
	var frames: SpriteFrames = player.sprite.sprite_frames
	if portrait.sprite_frames != frames:
		portrait.sprite_frames = frames
	if frames.has_animation("idle_down"):
		portrait.play("idle_down")


func _refresh_if_open() -> void:
	if visible:
		_refresh()


func _refresh() -> void:
	_build_stats()
	_build_buffs()
	_build_inventory()


# ---------------- PANEL KIRI: STAT ----------------
func _build_stats() -> void:
	for c in stats_box.get_children():
		c.queue_free()
	_add_stat_row("level", "Level %d" % GameState.level)
	_add_stat_row("level", "XP %d / %d" % [GameState.xp, GameState.XP_PER_LEVEL])
	_add_stat_row("hp", "HP %d / %d" % [GameState.hp_current, GameState.hp_max])
	_add_stat_row("damage", "Damage %d" % GameState.damage)
	_add_stat_row("coins", "Koin %d" % GameState.coins)


func _add_stat_row(key: String, text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var icon := TextureRect.new()
	icon.texture = STAT_ICONS[key]
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_color", TEXT_DARK)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(icon)
	row.add_child(label)
	stats_box.add_child(row)


# ---------------- PANEL KANAN: INVENTORY ----------------
func _build_inventory() -> void:
	var keep := _selected_id
	item_list.clear()
	_selected_id = &""
	use_btn.visible = false
	desc_label.text = "Belum ada item." if GameState.inventory.is_empty() else "Pilih item untuk melihat deskripsi."
	for id in GameState.inventory:
		var data := GameState.get_item_data(id)
		if data == null:
			continue
		var idx := item_list.add_item("%s  x%d" % [data.display_name, GameState.get_count(id)], data.icon)
		item_list.set_item_metadata(idx, id)
		if id == keep:
			item_list.select(idx)
			_on_item_selected(idx)


func _on_item_selected(index: int) -> void:
	_selected_id = item_list.get_item_metadata(index)
	var data := GameState.get_item_data(_selected_id)
	if data == null:
		return
	var text := data.description
	if data.sell_price > 0:
		text += "\nHarga jual: %d koin" % data.sell_price
	desc_label.text = text
	var usable := (data.type == ItemData.Type.CONSUMABLE and data.heal_amount > 0) \
		or data.type == ItemData.Type.BOOSTER
	use_btn.visible = usable
	use_btn.disabled = false
	if data.type == ItemData.Type.BOOSTER:
		var used: int = GameState.boosts.get(data.boost_id, 0)
		var limit: int = GameState.BOOST_MAX.get(data.boost_id, 0)
		use_btn.disabled = used >= limit
		desc_label.text = text + "\nTerpakai: %d/%d" % [used, limit]

func _on_use_pressed() -> void:
	if _selected_id != &"":
		GameState.use_item(_selected_id)

# ---------------- PANEL KIRI: PENGUAT (BUFF) ----------------
func _build_buffs() -> void:
	for c in buff_box.get_children():
		c.queue_free()

	var any := false
	for id in GameState.BOOST_INFO:
		var count: int = GameState.boosts.get(id, 0)
		if count <= 0:
			continue
		if not any:
			any = true
			var header := Label.new()
			header.text = "PENGUAT"
			header.add_theme_font_size_override("font_size", 34)
			header.add_theme_color_override("font_color", TEXT_DARK.lightened(0.25))
			buff_box.add_child(header)

		var info: Dictionary = GameState.BOOST_INFO[id]
		var limit: int = GameState.BOOST_MAX[id]

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		var icon := TextureRect.new()
		icon.texture = load(info.icon)
		icon.custom_minimum_size = Vector2(80, 80)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		var name_l := Label.new()
		name_l.text = "%s  %d/%d" % [info.name, count, limit]
		name_l.add_theme_font_size_override("font_size", 38)
		name_l.add_theme_color_override("font_color", TEXT_DARK)
		var desc_l := Label.new()
		desc_l.text = "+%d %s" % [info.per * count, info.stat]
		desc_l.add_theme_font_size_override("font_size", 34)
		desc_l.add_theme_color_override("font_color", Color("#6b5a3e"))
		col.add_child(name_l)
		col.add_child(desc_l)

		row.add_child(icon)
		row.add_child(col)
		buff_box.add_child(row)
