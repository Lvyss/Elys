# Rekap Proyek Godot, Doc 3 (Peta A, Kamera, dan Kontrol)

## ✅ Yang Sudah Jadi di Sesi Ini

### Batas Hutan dan Lantai Luar

- **OuterGround**: PlaneMesh 80x80 di Y -0.05 untuk menutup jurang. Materialnya diganti ke tekstur `grass_tile.png` yang digelapkan (UV1 Scale sekitar 62) supaya sambungan dengan lantai utama tidak kasar
- **Scene placeholder**: `tree.tscn` (pinus dari silinder), `rock.tscn` (bola low-poly bersudut), `bush.tscn` (semak pendek, di bawah 1 m)
- **`scatter.gd`** (`@tool`): menyebar objek acak di sebuah kotak area, dengan Count, Area Min/Max, Scale Range, Random Seed, dan tombol Regenerate
- **Node di bawah `Boundary`**:
  - Pohon: TreesNorth, TreesWest, TreesEast (West dan East diperpanjang ke Z 10, Count 24)
  - Batu: RocksNorth, RocksWest, RocksEast, RocksSouthWest, RocksSouthEast
  - Semak tepi: EdgeNorth, EdgeWest, EdgeEast, EdgeSouthWest, EdgeSouthEast (selatan punya celah X -2.5 sampai 2.5 untuk jalan)
- Tepi selatan hanya batu dan semak pendek supaya tidak menutupi hero di depan kamera

### Kamera Orbit dengan Mouse (`camera_follow.gd`)

- Mouse memutar kamera mengelilingi hero (yaw dan pitch), scroll untuk zoom (jarak 4 sampai 16)
- Sudut awal dibaca dari posisi kamera di editor (pitch -26°, yaw 20°, jarak 10)
- Batas kamera (`limit_min`/`limit_max`) dihapus, kamera selalu mengikuti hero sampai pojok
- **Bisa mendongak**: `min_pitch_deg = -35`, makin mendongak jarak otomatis dipendekkan supaya kamera tidak tembus tanah (`min_cam_height 0.4`, `close_distance 1.5`)
- Skrip harus dipasang di node bertipe **Camera3D** (sempat error karena terpasang ke Node3D, sudah beres)
- Esc melepas kursor, klik kiri menangkap lagi

### Kontrol Hero (`player.gd`)

- Gerak WASD sekarang **mengikuti arah kamera** (forward dan right diratakan ke tanah), jadi W selalu menjauh dari kamera
- Animasi dan `flip_h` tetap memakai `input` (arah di layar), karena sprite Y-Billboard
- Error `speed` tidak dikenal sudah diperbaiki, konstantanya `SPEED` (huruf besar)

### Fullscreen dan Keluar

- Fullscreen: lewat Project Settings (Display > Window > Mode) atau toggle **F11** lewat skrip
- Esc untuk keluar: tersedia versi langsung `get_tree().quit()` dan versi dua tahap (Esc pertama lepas kursor, Esc kedua keluar). Dianjurkan versi dua tahap

---

## ⚠️ Perlu Dicek atau Diputuskan

1. **Hasil visual belum dikonfirmasi** setelah semak tepi dan batu depan ditambahkan. Cek lewat Preview kamera game, bukan tampilan editor yang zoom out.
2. **Pohon bisa menutupi kamera** karena sekarang kamera bisa berputar 360°. Opsi nanti: pohon jadi transparan saat menutupi hero, atau batasi jarak kamera.
3. **Fungsi Esc keluar dan F11** belum jelas sudah dipasang atau belum. Pilih satu versi Esc dan tempel di skrip.
4. **Versi web**: `quit()` tidak menutup tab, dan fullscreen butuh aksi pemain. Perlu menu pause dan tombol fullscreen di versi web.
5. **Kamera tanah datar**: batas tanah memakai angka tetap `ground_height = 0`. Kalau nanti ada bukit, perlu RayCast.

---

## 📌 Belum Dikerjakan

- [ ] **Dinding tak terlihat** dan **collision landmark** (Hut, ChestPedestal, batu altar). Tahap 4 lama, belum ada konfirmasi
- [ ] **Cahaya**: DirectionalLight3D, WorldEnvironment (fog, ambient, contrast), OmniLight gubuk (Tahap 5 lama)
- [ ] **Collision pohon dan batu** hasil scatter (sekarang cuma visual)
- [ ] **Aset asli**: ganti placeholder dengan Kenney Nature Kit atau pack CC0 lain, catat di `CREDITS.md`
- [ ] **Detail kecil**: props (pagar, batang kayu, tunggul, tong, lampion), jamur, bunga, rumput tinggi
- [ ] **Efek**: sinar matahari, kunang-kunang, vignette
- [ ] **Uji ekspor web** (belum pernah dicoba)
- [ ] Sisa dari Doc 1 dan 2: collision layer, group `enemy`, goblin sesuai GDD, serang hero dan HP, slime, `level_1.tscn`

Peta Koordinat Peta A (Doc 3b, referensi posisi)
Cara baca koordinat
Satuan: meter, posisi dunia (global). Semua induk (MapA, Landmarks, Boundary) harus di (0, 0, 0).
X minus = kiri (barat), X plus = kanan (timur).
Z minus = utara (jauh dari kamera awal), Z plus = selatan (dekat kamera awal).
Y = tinggi. Tanah di Y = 0.
Lantai utama 18 x 18, jadi arena membentang X -9 sampai 9 dan Z -9 sampai 9.
Di Inspector, Area Min/Max bertipe Vector2: kolom Y di sana artinya Z dunia.
Konversi dari gambar denah (347 x 350 px): x = (px/347 - 0.5) x 18, z = (py/350 - 0.5) x 18.
Sketsa dari atas (1 kotak kira-kira 2 m)
UTARA (Z -)
X -9 0 9
Z -9 ┌────────────────────┐
│ [Peti] ║ [Gubuk]│ Peti (-6,-6)
Z -6 │ ▪ ║ ▓▓ │ Gubuk (5,-7)
│ ╲ ║ ╱ │
Z -3 │ ╲ ║ ╱ │
│ ╲ ║ ╱ │
Z 0 │ ▌▐▌══╗ ║ ╔ │ Altar (-5.5,0.5)
│ ╚═╬═╝ │
Z 3 │ ║ │
│ ║ │
Z 6 │ ║ │
│ ║ │
Z 9 └──────────╨─────────┘
★ Spawn (0,8)
SELATAN (Z +)

Celah jalan ke utara ada di (0, -8.8). Garis ║ adalah jalan tanah utama dari selatan ke utara, dengan cabang ke altar, peti, dan gubuk.

Titik utama
Objek Posisi (X, Y, Z) Catatan
Spawn hero (0, 0, 8) Kamera dihitung dari titik ini
Celah jalan utara (0, 0, -8.8) Jalan keluar ke level berikutnya (rencana)
Hut (induk) (5, 0, -7) Pintu menghadap selatan
ChestPedestal (induk) (-6, 0, -6)
Altar (induk) (0, 0, 0) Hanya folder, jangan digeser
Pusat altar (-5.5, 0, 0.5) Titik tengah 3 batu
Isi Hut (posisi dunia, induk di 5, 0, -7)
Bagian Lokal Dunia Ukuran
Walls (0, 1.0, 0) (5, 1.0, -7) 3.2 x 2.0 x 2.6
Roof (0, 2.65, 0), rot Y 90 (5, 2.65, -7) Prisma 3.0 x 1.3 x 3.8
Door (-0.7, 0.7, 1.31) (4.3, 0.7, -5.69) 0.8 x 1.4 x 0.05
Window (0.9, 1.2, 1.31) (5.9, 1.2, -5.69) 0.6 x 0.6 x 0.05, emisi oranye
OmniLight3D (0.9, 1.2, 2.0) (5.9, 1.2, -5.0) Energy 1.2, Range 3
Collision (0, 1, 0) (5, 1, -7) 3.2 x 2 x 2.6
Isi ChestPedestal (induk di -6, 0, -6)
Bagian Dunia Ukuran
Base (-6, 0.25, -6) 1.6 x 0.5 x 1.6
Chest (-6, 0.775, -6) 0.9 x 0.55 x 0.6
Collision (-6, 0.5, -6) 1.6 x 1 x 1.6
Tiga batu altar (ukuran 0.5 x 1.4 x 0.3)
Batu Posisi dunia Rotasi Y
Stone1 (-7.0, 0.7, 1.4) -20°
Stone2 (-5.5, 0.7, 0.4) 0°
Stone3 (-4.0, 0.7, 1.4) 20°

Kalau nanti memakai posisi relatif dengan induk Altar di (-5.5, 0, 0.5): Stone1 (-1.5, 0.7, 0.9), Stone2 (0, 0.7, -0.1), Stone3 (1.5, 0.7, 0.9).

Dinding tak terlihat (Walls, StaticBody3D)
Nama Posisi Ukuran
WallNorth (0, 2, -9.5) 18 x 4 x 1
WallSouth (0, 2, 9.5) 18 x 4 x 1
WallWest (-9.5, 2, 0) 1 x 4 x 18
WallEast (9.5, 2, 0) 1 x 4 x 18
Lantai
Node Posisi Ukuran Catatan
Ground (0, 0, 0) 18 x 18 ShaderMaterial, tile_count 14
OuterGround (0, -0.05, 0) 80 x 80 UV1 Scale 62
Zona sebar (scatter.gd, di bawah Boundary)

Kolom area memakai format (X, Z).

Node Item Count Area Min Area Max Scale Seed
TreesNorth tree 30 (-18, -20) (18, -10.5) 1.2-1.8 1
TreesWest tree 24 (-18, -10) (-10.5, 10) 1.2-1.8 2
TreesEast tree 24 (10.5, -10) (18, 10) 1.2-1.8 3
RocksNorth rock 14 (-14, -12) (14, -9.5) 1.5-2.5 4
RocksWest rock 6 (-12, -9) (-9.8, 5) 1.0-1.8 5
RocksEast rock 6 (9.8, -9) (12, 5) 1.0-1.8 6
RocksSouthWest rock 6 (-14, 10) (-3, 13) 0.7-1.3
RocksSouthEast rock 6 (3, 10) (14, 13) 0.7-1.3
EdgeNorth bush 14 (-10, -10) (10, -8.6) 0.8-1.4 11
EdgeWest bush 14 (-10, -9) (-8.6, 9) 0.8-1.4 12
EdgeEast bush 14 (8.6, -9) (10, 9) 0.8-1.4 13
EdgeSouthWest bush 8 (-10, 8.6) (-2.5, 10.2) 0.8-1.4 14
EdgeSouthEast bush 8 (2.5, 8.6) (10, 10.2) 0.8-1.4 15

Aturan yang perlu diingat: celah jalan di selatan adalah X -2.5 sampai 2.5, jangan diisi apa pun.

Kamera (posisi awal di editor)
Properti Nilai
Position (3.1, 5.4, 16.5)
Rotation (-26, 20, 0)
FOV 30
Titik pandang (0, 1, 8), setinggi dada hero

Rumus offset: posisi = target + (D cos P sin Yaw, D sin P, D cos P cos Yaw).

Slot kosong untuk pengerjaan berikutnya

Ini usulan supaya tidak bentrok dengan yang sudah ada, bisa diubah.

Rencana Area yang aman Catatan
Slime hijau (Level 1) Padang kiri (X -8 sampai -2, Z 2 sampai 8) dan semak kanan (X 3 sampai 8, Z -4 sampai 5) Hindari jalan tanah
Props dekat gubuk Sekitar (3 sampai 8, Z -6 sampai -4) Tong, peti kecil, lampion
Pagar pemandu Kiri jalan, X sekitar -2, Z 0 sampai 6 Tinggi di bawah 1 m
Pohon tinggi Hanya utara, barat, timur Jangan di selatan, menutupi kamera
