@tool
extends EditorScript

const ICON_DIR := "res://assets/icons/items/"
const OUT_DIR := "res://data/items/"

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var C := ItemData.Type.COLLECTIBLE
	var P := ItemData.Type.CONSUMABLE
	var Q := ItemData.Type.QUEST
	var B := ItemData.Type.BOOSTER
	# [id, nama, deskripsi, tipe, harga jual, heal, boost_id, file ikon ("" = sama dengan id)]
	var items := [
		["taring_goblin", "Taring Goblin", "Taring tajam milik Goblin Prajurit. Jual atau tukar jadi Ramuan Taring (3 buah).", C, 12, 0, "", ""],
		["lempeng_besi", "Lempeng Besi", "Pelat besi dari Goblin Elit. Jual atau tukar jadi Asah Besi (2 buah).", C, 25, 0, "", ""],
		["kristal_kabut", "Kristal Kabut", "Kristal berkabut dari Goblin Raja. Jual atau tukar jadi Berkat Kabut.", C, 40, 0, "", ""],
		["ramuan_taring", "Ramuan Taring", "Ramuan hasil tukar. Memulihkan 40 HP. Tombol Q.", P, 0, 40, "", ""],
		["ramuan_hijau", "Ramuan Hijau", "Ramuan dari Toko Orrin. Memulihkan 40 HP. Tombol Q.", P, 0, 40, "", ""],
		["gulungan_petunjuk", "Gulungan Petunjuk", "Menghilangkan 1 pilihan salah di teka-teki rune.", P, 0, 0, "", ""],
		["pecahan_rune_1", "Pecahan Rune I", "Pecahan pertama, bersimbol ◐.", Q, 0, 0, "", ""],
		["pecahan_rune_2", "Pecahan Rune II", "Pecahan kedua, bersimbol ◑.", Q, 0, 0, "", ""],
		["pecahan_rune_3", "Pecahan Rune III", "Pecahan ketiga, bersimbol ◒.", Q, 0, 0, "", ""],
		["asah_besi", "Asah Besi", "Tempa bilah senjatamu. Pakai untuk +5 Damage permanen (maks 2 kali).", B, 0, 0, "asah_besi", "booster_asah_besi"],
		["berkat_kabut", "Berkat Kabut", "Kabut menyelimuti tubuhmu. Pakai untuk +30 Max HP permanen (maks 3 kali).", B, 0, 0, "berkat_kabut", "booster_berkat_kabut"],
	]
	for d in items:
		var it := ItemData.new()
		it.id = d[0]
		it.display_name = d[1]
		it.description = d[2]
		it.type = d[3]
		it.sell_price = d[4]
		it.heal_amount = d[5]
		it.boost_id = d[6]
		var icon_file: String = d[7] if d[7] != "" else d[0]
		var path: String = ICON_DIR + icon_file + ".png"
		if ResourceLoader.exists(path):
			it.icon = load(path)
		else:
			push_warning("Ikon tidak ada: " + path)
		ResourceSaver.save(it, OUT_DIR + d[0] + ".tres")
	EditorInterface.get_resource_filesystem().scan()
	print("Selesai: ", items.size(), " item dibuat")
