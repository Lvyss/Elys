# 📋 RANGKUMAN DOC 9: HUD, STATUS WINDOW, INVENTORY, LOOT, TOKO ORRIN

Lanjutan dari Doc 8. Fokus sesi ini: antarmuka gameplay dan ekonomi item, sampai alur lengkap **bunuh goblin → drop → inventory → jual/tukar/beli → pakai → buff** berjalan.

---

## 🧱 1. KONFIGURASI DASAR UI

| Item                                  | Nilai                                                       |
| ------------------------------------- | ----------------------------------------------------------- |
| Viewport                              | **1152×648** (GDD 3.x menulis 1280×720, perlu disinkronkan) |
| Stretch                               | Mode `canvas_items`, Aspect `keep`                          |
| Filter HUD/panel                      | **Linear** (art halus)                                      |
| Filter ikon item/atribut dan ItemList | **Nearest** (pixel art)                                     |
| Impor ikon                            | Preset **2D Pixel**, lalu Reimport                          |
| Input baru                            | `profile` (**C**), `use_potion` (**Q**), `interact` (**E**) |

**Aturan skala yang dipakai di semua UI:** node `Bar`/`Window` memakai Size sebesar PNG aslinya, lalu **hanya Scale yang diubah**. Semua anak memakai **koordinat piksel PNG**, jadi tidak perlu menghitung ulang saat skala berubah.

---

## 🎮 2. HUD (`hud.tscn`, script `hud.gd`)

### Struktur

```
HUD (CanvasLayer)  ← hud.gd
└─ Root (Control) [Full Rect, Mouse Filter Ignore]
   └─ Bar (Control) [Scale diatur di sini, Anchor Center Bottom]
      ├─ HPBar (TextureProgressBar)   ← lubang atas frame, PNG fill hijau
      ├─ XPBar (TextureProgressBar)   ← lubang bawah frame, PNG fill kuning
      ├─ Frame (TextureRect)          ← PNG frame hexagon (transparan)
      ├─ DashSlot (Control)
      │   ├─ Icon (TextureRect)       ← ikon sepatu orange
      │   ├─ CDOverlay (TextureProgressBar)  ← Clockwise, tint #000000b0
      │   └─ CDLabel (Label)          ← Visible off, angka sisa cooldown
      └─ ProfileSlot (TextureButton)  ← hexagon kanan, ikon profil krem
```

Urutan tree penting: HPBar dan XPBar **di atas** Frame (digambar di belakang), sehingga terlihat lewat lubang frame. Posisi akhir node di dalam Bar mengikuti penempatanmu di editor (tidak dicatat angkanya).

### Pelajaran teknis

- `TextureProgressBar` memotong berdasarkan **ukuran tekstur**, bukan Size node. `GradientTexture2D` dan Nine Patch Stretch bikin Value tidak berefek. **Pakai PNG fill biasa**, Nine Patch off, dan kecilkan lewat Scale parent.
- Mouse Filter semua node HUD `Ignore`, kecuali `ProfileSlot`.

### Perilaku (`hud.gd`)

- `add_to_group("hud")`, memancarkan sinyal `profile_pressed` (klik ProfileSlot atau tombol **C**).
- Mendengar `GameState.hp_changed` dan `GameState.xp_changed`, nilai bar bergerak halus lewat Tween 0.25 detik.
- `_process` mencari player lewat group `player` (lazy), membaca `player.get_dash_ratio()` untuk overlay dan `player.dash_cooldown_timer` untuk angka.
- Hexagon kiri frame masih kosong (cadangan skill/item lain).

### Bug yang sudah beres

- Error `null instance` pada `.text`: berasal dari **script map lama** yang masih mencari `$CanvasLayer/HealthLabel`. Script map dibersihkan.
- Error `toggle` pada null: baris `$HUD.profile_pressed.connect($StatusWindow.toggle)` salah ditaruh di `hud.gd`. Dihapus, sambungan dipindah ke StatusWindow.

---

## 🧍 3. PERUBAHAN `player.gd`

| Penambahan                                           | Fungsi                                                                  |
| ---------------------------------------------------- | ----------------------------------------------------------------------- |
| `get_dash_ratio()`                                   | 1.0 saat dash, selain itu `dash_cooldown_timer / DASH_COOLDOWN`         |
| Blok `use_potion` di `_unhandled_input`              | Q memakai **Ramuan Taring dulu**, kalau tidak ada baru **Ramuan Hijau** |
| Blok `if GameState.ui_open` (setelah blok `is_dead`) | Hero berhenti dan animasi idle saat window terbuka                      |

Catatan: `DASH_COOLDOWN` 0.6 detik (disarankan 1.0 sampai 1.5 supaya overlay terasa).

---

## 🗃️ 4. DATA ITEM

### `ItemData` (Resource, `res://scripts/item_data.gd`)

Field: `id`, `display_name`, `description`, `icon`, `type`, `sell_price`, `heal_amount`, `boost_id`.
Enum `Type`: `COLLECTIBLE`, `CONSUMABLE`, `QUEST`, **`BOOSTER`** (ditambah di paling belakang agar `.tres` lama aman).

### 11 item (`res://data/items/*.tres`, dibangun oleh `res://tools/build_items.gd`)

| ID                   | Nama                  | Tipe        | Jual | Efek                |
| -------------------- | --------------------- | ----------- | ---- | ------------------- |
| `taring_goblin`      | Taring Goblin         | Collectible | 12   | Bahan               |
| `lempeng_besi`       | Lempeng Besi          | Collectible | 25   | Bahan               |
| `kristal_kabut`      | Kristal Kabut         | Collectible | 40   | Bahan               |
| `ramuan_taring`      | Ramuan Taring         | Consumable  | 0    | +40 HP              |
| `ramuan_hijau`       | Ramuan Hijau          | Consumable  | 0    | +40 HP              |
| `gulungan_petunjuk`  | Gulungan Petunjuk     | Consumable  | 0    | Belum ada efek      |
| `pecahan_rune_1/2/3` | Pecahan Rune I/II/III | Quest       | 0    | Belum dipakai       |
| `asah_besi`          | Asah Besi             | **Booster** | 0    | +5 Damage, maks 2x  |
| `berkat_kabut`       | Berkat Kabut          | **Booster** | 0    | +30 Max HP, maks 3x |

### Ikon (16 file)

- `res://assets/icons/items/`: taring_goblin, lempeng_besi, kristal_kabut, ramuan_taring, ramuan_hijau, gulungan_petunjuk, pecahan_rune_1/2/3, booster_asah_besi, booster_berkat_kabut
- `res://assets/icons/stats/`: icon_hp, icon_damage, icon_xp, icon_koin, icon_speed

---

## 🧠 5. `GameState` (tambahan)

| Elemen                                                            | Keterangan                                                                                      |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `coins`, sinyal `coins_changed`                                   | Koin awal 0                                                                                     |
| `inventory: Dictionary` (id → jumlah), sinyal `inventory_changed` |                                                                                                 |
| `get_item_data(id)`, `get_count(id)`                              | Memuat `.tres` dari `ITEM_DIR`                                                                  |
| `add_item`, `remove_item`, `add_coins`, `spend_coins`             |                                                                                                 |
| `sell_item(id)`                                                   | Hapus 1 item, tambah koin sesuai `sell_price`                                                   |
| `use_item(id)`                                                    | `match` tipe: Consumable → heal (gagal kalau HP penuh), Booster → `apply_boost` lalu hapus item |
| `boosts` (`asah_besi`, `berkat_kabut`) + `BOOST_MAX` (2 dan 3)    | Jumlah booster yang **sudah dipakai**                                                           |
| `BOOST_INFO`                                                      | Nama, stat, nilai per pemakaian, path ikon (untuk panel Penguat)                                |
| `apply_boost(id)`                                                 | Asah Besi +5 `damage`, Berkat Kabut +30 `hp_max` dan `hp_current`                               |
| `boost_total(id)`                                                 | Terpakai + masih tersimpan di inventory (membatasi tukar di toko)                               |
| `ui_open`                                                         | `true` saat window status/toko terbuka (hero berhenti)                                          |

⚠️ **Data tes di `_ready()` perlu dihapus** sebelum rilis: `add_item(...)` beberapa baris dan `coins = 50`.

---

## 🪟 6. STATUS WINDOW (`status_window.tscn`, `status_window.gd`)

### Background dan node `Window`

- Gambar: `stat_window.png`, **1773×1534**, RGBA transparan.
- Tinggi tampil = **80% layar** (518 px), jadi Scale = 518 ÷ 1534 = **0.338**.

| Properti `Window` | Nilai        |
| ----------------- | ------------ |
| Size              | 1773 × 1534  |
| Position          | -310.5, -443 |
| Pivot Offset      | 886.5, 767   |
| Scale             | 0.338, 0.338 |

Rumus ubah ukuran: `scale = (648 × persen) ÷ 1534`.

### Pembagian area panel (piksel PNG)

| Area                    | Koordinat (x, y)    | Dipakai untuk         |
| ----------------------- | ------------------- | --------------------- |
| Panel krem kiri         | 65–648, 197–1435    | Potret, stat, penguat |
| Ceruk gelap kiri atas   | 235–480, 197–248    | (Toko: nama NPC)      |
| Panel gelap besar kanan | 703–1652, 313–1100  | Daftar item           |
| Panel gelap kecil kanan | 703–1652, 1126–1395 | Deskripsi dan tombol  |
| Tab atas                | 985–1375, 115–180   | Judul                 |
| Lingkaran tutup         | pusat (1658, 227)   | Tombol tutup          |

### Struktur dan posisi (anak `Window`)

```
StatusWindow (CanvasLayer) ← Visible off
└─ Root (Control) [Full Rect, Mouse Filter Stop]
   └─ Window
      ├─ Background   0,0      1773×1534 (Mouse Filter Ignore)
      ├─ Portrait     AnimatedSprite2D, geser naik/kecil, muat y 270–740
      ├─ StatsBox     100, 760   530×350   (VBoxContainer, 5 baris)
      ├─ BuffBox      100, 1140  530×260   (VBoxContainer, panel Penguat)
      ├─ TitleLabel   700, 197   900×58    "INVENTORY", font 44, cokelat
      ├─ ItemList     730, 335   900×745
      ├─ DescLabel    735, 1145  680×230   (Autowrap Smart, font 44, krem)
      ├─ UseBtn       1440, 1215 190×100
      └─ CloseBtn     1623, 192  70×70     (Flat, semua style StyleBoxEmpty)
```

_(Nilai awal sebelum BuffBox: Portrait di 356,560 Scale 6; StatsBox di 100,880 530×520. Sesuaikan dengan hasil geseranmu.)_

### Isi

- **Kiri atas:** idle hero (`idle_down`, diambil dari SpriteFrames player, Filter Nearest).
- **Kiri tengah (StatsBox):** Level, XP x/30, HP x/max, Damage, Koin. Ikon 64 px, font 40, separation 16, warna `#3b2a1e`.
- **Kiri bawah (BuffBox, "PENGUAT"):** muncul **hanya setelah booster dipakai**. Satu baris per buff: ikon 80 px, `Nama  n/maks`, `+X Stat`.
- **Kanan atas:** `ItemList` item beserta jumlah, tanpa grid.
- **Kanan bawah:** deskripsi (plus harga jual), tombol **Pakai** (hanya Consumable dan Booster; Booster mati kalau sudah maks, menampilkan `Terpakai n/maks`).

### Pengaturan ItemList

Select Mode Single, Icon Mode Left, Fixed Icon Size 88×88, Filter Nearest, font 52, warna `#e8dcc0`. Style **Selected** dan **Selected Focus**: StyleBoxFlat bg `#d4af3740`, border 3 px `#d4af37`. Style **Panel**: StyleBoxEmpty.

### Perilaku

- **C** atau klik hexagon profil membuka/menutup (`toggle`). Tersambung otomatis: `_connect_hud.call_deferred()` mencari node group `hud`.
- Saat buka: kursor bebas, `GameState.ui_open = true`. Saat tutup: kursor tertangkap, `ui_open = false`.
- **Esc menutup window ini lebih dulu**, bukan membuka pause.
- Memperbarui diri lewat sinyal `hp_changed`, `xp_changed`, `coins_changed`, `inventory_changed`.

### Bug yang sudah beres

- `null instance` pada `title_label.text`: node belum **Access as Unique Name (%)**. Wajib untuk Portrait, StatsBox, BuffBox, TitleLabel, ItemList, DescLabel, UseBtn, CloseBtn.

---

## 💀 7. LOOT GOBLIN

### `GoblinStats` (grup baru **Loot**)

`xp_reward`, `drop_item_id`, `drop_chance` (0 sampai 1).

| Kartu              | XP  | Drop            | Peluang |
| ------------------ | --- | --------------- | ------- |
| `goblin_lv1.tres`  | 10  | `taring_goblin` | 0.7     |
| `goblin_lv2.tres`  | 25  | `lempeng_besi`  | 0.8     |
| `goblin_boss.tres` | 60  | `kristal_kabut` | 1.0     |

### `goblin.gd`

- Logika XP lama (`if size_scale > 1.5` dan `max_hp > 50`) **dihapus**, diganti `GameState.add_xp(stats.xp_reward)` dan `_drop_loot()`.
- `_drop_loot()`: cek id kosong dan `randf() > drop_chance`, buat `ItemPickup`, ditaruh di **parent goblin** (bukan anak, agar tidak ikut `queue_free` dan tidak ikut ter-scale), offset acak ±0.3 m.

### `item_pickup.gd` (`class_name ItemPickup`, murni kode)

| Konstanta                        | Nilai       |
| -------------------------------- | ----------- |
| `PICKUP_RADIUS`                  | 1.0 m       |
| `MAGNET_RADIUS` / `MAGNET_SPEED` | 2.5 m / 8.0 |
| `PICKUP_DELAY`                   | 0.6 s       |
| `HOVER_HEIGHT`                   | 0.45 m      |

Sprite3D billboard, Nearest, Alpha Cut Discard, tinggi ikon sekitar 0.5 m (`pixel_size = 0.5 / lebar`). Efek: naik lalu melayang (sin), tersedot ke hero, teks `+ Nama Item` naik dan memudar, lalu `GameState.add_item`.

---

## 🛒 8. TOKO ORRIN

### NPC `orrin.tscn` (`orrin.gd`)

```
Orrin (StaticBody3D)  ← group "npc"
├─ AnimatedSprite3D   ← Y-Billboard, Nearest, Alpha Cut Discard, Shaded, Pixel Size 0.02, animasi "idle" (autoplay)
├─ CollisionShape3D   ← CapsuleShape3D radius ~0.4, tinggi ~1.4, Position Y ~0.7
└─ Prompt (Label3D)   ← "E: Bicara dengan Orrin", Y 2.0, Billboard Enabled, No Depth Test, Pixel Size 0.006, Outline 12, Visible off
```

- `TALK_RANGE` 2.0 m dari origin. Prompt tampil saat dekat dan toko tertutup. **E** memanggil `shop.open()` (node group `shop`).
- Posisi sementara: **(3.5, 0, -5.5)** dekat gubuk (interior gubuk belum ada).
- Bayangan: AnimatedSprite3D harus **Alpha Cut Discard**, Cast Shadow On. Opsi lanjutan: `ShadowSprite` terpisah seperti hero.

### `shop_window.tscn` (`shop_window.gd`)

Memakai **panel dan node `Window` identik** dengan status window (ukuran, Position, Pivot, Scale sama). Root `ShopWindow` (CanvasLayer, Visible off, group `shop`).

| Node                        | Position             | Size      | Isi                                      |
| --------------------------- | -------------------- | --------- | ---------------------------------------- |
| Background                  | 0, 0                 | 1773×1534 | `stat_window.png`                        |
| NameLabel                   | 235, 200             | 245×48    | "ORRIN", font 36, krem                   |
| Portrait                    | 120, 290             | 420×420   | Potret (opsional, Nearest)               |
| DialogLabel                 | 95, 730              | 525×170   | Dialog, font 38, cokelat                 |
| BtnSell / BtnTrade / BtnBuy | 95 / 930, 1050, 1170 | 525×100   | Toggle, ButtonGroup, font 52             |
| CoinIcon                    | 95, 1310             | 80×80     | `icon_koin.png`                          |
| CoinLabel                   | 190, 1310            | 430×80    | Jumlah koin                              |
| TitleLabel                  | 700, 197             | 900×58    | "TOKO ORRIN"                             |
| ItemList                    | 730, 335             | 900×745   | Seperti status window                    |
| DescLabel                   | 735, 1145            | 680×230   | Krem, font 44                            |
| ActionBtn                   | 1440, 1215           | 190×100   | Jual / Tukar / Beli (ada state disabled) |
| CloseBtn                    | 1623, 192            | 70×70     | Flat                                     |

Gaya tombol mode: normal `#a89a6e`, pressed `#d4af37`, hover `#c0b284`, border 3 px `#5c4a3a`, disabled `#8a806a`.

### Tiga mode

| Mode      | Isi                                                                       | Aturan                                                                                                                                                                 |
| --------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Jual**  | Item inventory ber-`sell_price` > 0                                       | Taring 12, Lempeng 25, Kristal 40                                                                                                                                      |
| **Tukar** | Ramuan Taring (3 Taring), Asah Besi (2 Lempeng), Berkat Kabut (1 Kristal) | Hasil tukar **masuk inventory** (tidak langsung dipakai). Daftar menampilkan `n/maks` dari `boost_total`. Redup dan tombol mati kalau bahan kurang atau batas tercapai |
| **Beli**  | Ramuan Hijau 20 koin, Gulungan Petunjuk 30 koin                           | Redup kalau koin kurang                                                                                                                                                |

Tutup dengan **E**, **Esc**, atau lingkaran kanan atas. Dialog berubah setelah tiap transaksi.

### Bug yang sudah beres

- `Cannot infer the type of "maxed"`: ditulis `var maxed: bool = ...`.
- `shop ditemukan: <null>`: instance `ShopWindow` belum ada di map atau skrip belum terpasang (grup `shop` didaftarkan di `_ready`).

---

## 🔄 9. ALUR LENGKAP YANG SUDAH JALAN

1. Bunuh goblin → XP dan peluang drop.
2. Dekati item → tersedot, `+ Nama Item`, masuk inventory.
3. **C** → status window: karakter, stat, daftar item, deskripsi.
4. **E** di Orrin → toko: jual, tukar, beli.
5. Tukar booster → item masuk inventory → **Pakai** dari inventory → stat naik permanen → panel **PENGUAT** menampilkan ikon, nama `n/maks`, dan `+X Stat`.
6. **Q** → minum ramuan (Taring dulu, lalu Hijau).

---

## ⚠️ 10. BEDA DARI GDD (perlu dicatat)

1. Resolusi dasar **1152×648** (GDD 1280×720).
2. HUD: bar HP/XP di **tengah bawah** dalam frame hexagon, bukan kiri/kanan atas (GDD 5.7). Koin tidak di HUD, hanya di status window dan toko.
3. Tombol **C** untuk status window (tidak ada di GDD 3.2).
4. Inventory berbentuk **daftar klik-pilih**, bukan grid.
5. Booster **disimpan sebagai item dan dipakai manual** (GDD 3.5: tukar langsung jadi booster).
6. Toko dibuka di **luar gubuk** (GDD: di dalam gubuk).
7. Tombol Q memakai ramuan otomatis (Taring dulu); GDD menyebut action `use_potion`, konsisten.
8. **Statistik goblin tidak sinkron:** GDD 3.4 menulis Elit HP 70, detect 9, Raja HP 120, detect 10; `.tres` saat ini (rangkuman lama) Lv2 HP 60 detect 7, Boss HP 200. Pilih satu sumber kebenaran dan samakan.
9. Esc saat window UI terbuka menutup window dulu, baru pause.

---

## 📌 11. BELUM DIKERJAKAN

### Dari sesi ini

- [ ] Hapus data tes di `GameState._ready()`
- [ ] Efek **Gulungan Petunjuk** (hilangkan 1 pilihan salah di puzzle rune)
- [ ] Item **Pecahan Rune** (belum ada sumber dan penggunaan)
- [ ] Potret Orrin di toko (node Portrait kosong) dan sprite final Elderly Alchemist
- [ ] Pindahkan toko ke **interior gubuk** (transisi masuk/keluar)
- [ ] Ikon kecepatan belum dipakai (stat Speed tidak ditampilkan)
- [ ] Hexagon kiri HUD (slot kosong)
- [ ] Tes HUD, status window, dan toko di **ekspor web** (FPS, skala, klik saat kursor bebas)
- [ ] Penyimpanan data (save/load) belum ada
- [ ] Tuning `DASH_COOLDOWN`, `drop_chance`, harga, setelah balancing

### Sisa dari Doc 8 (masih berlaku)

- Collision layer sesuai GDD 6.7, collision batu/landmark/pohon scatter
- Hero `take_damage` sudah ada, cek ulang kebal 0.6 s dan efek kematian
- Visual peta (batang raksasa, landmark, gubuk model asli, clutter MultiMesh, pohon jauh)
- Atmosfer: matikan SSAO/SDFGI/Volumetric, SunRays, shadow 2 splits, kunang-kunang, vignette
- Web: export path, `.htaccess`, menu pause + fullscreen
- Home screen, loading screen, logo ELYS, tombol UI, menu utama
- Aset karakter (animasi goblin final, hero SOUTH pedang), `CREDITS.md`, update GDD, Manual Book HKI, video demo

---

## 🧭 12. LANGKAH BERIKUTNYA (URUTAN DISARANKAN)

1. **Bersihkan data tes** dan uji alur penuh dari awal (bunuh → drop → jual → tukar → pakai).
2. **Prompt interaksi dan tutorial dasar** (GDD 5.x: "E: Masuk gubuk", ambil item, tekan Q), plus HUD **koin** dan **progres zona** ("Prajurit 3/5, ...").
3. **Puzzle rune dan Pecahan Rune** (altar, pedestal, peti), termasuk efek Gulungan Petunjuk.
4. **Panel Level Selesai dan layar Kalah** (Coba Lagi).
5. **Menu pause + fullscreen** versi web.
6. **Ekspor web ulang**, cek FPS dan UI.
7. Kembali ke visual/atmosfer, lalu UI menu utama.
8. Finalisasi: sound, balancing, dokumentasi (CREDITS, GDD, HKI), video demo.

Mau lanjut yang nomor berapa?
