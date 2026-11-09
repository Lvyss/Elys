# Rekap Proyek Godot, Doc 7 (Goblin 4 Arah, Spawner, Kamera Anti-Tertutup, dan Kegelapan Tepi Peta)

## ✅ Yang Sudah Jadi di Sesi Ini

### Animasi goblin (4 arah, 8 aksi)

- Sprite Orc punya **8 aksi x 4 arah = 32 animasi**, dengan format nama `<aksi>_<arah>`
- Aksi: `idle`, `walk`, `run`, `attack`, `walk_attack`, `run_attack`, `hurt`, `death`
- Arah: `down`, `left`, `up`, `right`
- Kata `front` di nama file bukan soal arah hadap
- Yang **tidak loop**: `attack`, `walk_attack`, `run_attack`, `hurt`, `death` (skrip mengatur ini sendiri di `_ready()`)
- Pemakaian: `idle` untuk diam dan menunggu cooldown, `walk` untuk wander, `run` untuk mengejar, `attack` untuk serangan dekat, `walk_attack` untuk serangan jarak menengah sambil maju pelan, `run_attack` untuk lunge dari jauh
- File `orc1_walk_attack_front _with_shadow` punya **spasi di namanya**, perlu di-rename
- Sprite sudah punya bayangan bawaan, jadi cast shadow dari sprite bisa dobel (cek di game)

### Arsitektur goblin: satu scene, banyak kartu statistik

- Satu **`goblin.tscn`** dipakai ulang. Tidak ada scene anak untuk Lv1, Lv2, dan boss
- **`goblin_stats.gd`** (Resource `GoblinStats`) berisi `sprite_frames`, `tint`, `size_scale`, HP, damage, kecepatan, jarak deteksi, jarak serang, windup, cooldown, dan `can_stagger`
- Tiap jenis punya file frames sendiri (`goblin_lv1_frames.tres`, `goblin_lv2_frames.tres`, `goblin_boss_frames.tres`). **Nama animasinya harus sama persis** di ketiganya
- Tiga file stats:

| File | HP | Damage | Chase | Detect | Scale | Stagger |
|---|---|---|---|---|---|---|
| `goblin_lv1.tres` | 40 | 10 | 3.0 | 5 | 1.0 | ✅ |
| `goblin_lv2.tres` | 60 | 15 | 3.5 | 7 | 1.0 | ✅ |
| `goblin_boss.tres` | 200 | 25 | 2.5 | 5 | 2.2 (disarankan) | ❌ |

- Kalau sprite lv2 dan boss sudah beda warna dan ukuran dari sheet-nya, Tint diputihkan dan Scale dikembalikan ke 1.0
- Varian Rogue dan Mage (bonus GDD) nanti pakai **inherited scene** hanya kalau perilakunya beda

### `goblin.gd` (revisi)

- State: `IDLE`, `WANDER`, `CHASE`, `ATTACK`, `HURT`, `DEAD`
- Jenis serangan dipilih dari jarak ke hero: `STAND`, `WALK`, `LUNGE`
- Arah hadap dihitung relatif ke kamera (tetap benar saat kamera diputar mouse)
- `_action_of()` memperbaiki bug lama yang salah membaca `walk_attack_left` sebagai `walk`
- Boss: sprite dan collision ikut `size_scale`
- Jaring pengaman: kalau `y < -3`, goblin dikembalikan ke titik awal
- Serangan ke hero masih cuma `print`, karena hero belum punya `take_damage`

### Spawner (`enemy_spawner.gd`, node `Enemies` di `map_a.tscn`)

- 6 goblin lewat kode: **2 Lv1 kanan bawah, 3 Lv2 kiri atas dekat peti, 1 boss kiri bawah**
- Posisi awal: Lv1 (5.5, 5) dan (7, 2.5); Lv2 (-3.5, -5), (-5.5, -3), (-7.5, -3.5); boss (-6.5, 4.5)
- Masalah "boss kadang ada kadang tidak" disebabkan collision tebing atau pohon di titik spawn. Perbaikan:
  - `await physics_frame` dua kali sebelum spawn
  - Raycast mencari tinggi tanah
  - Cek bola untuk ruang kosong
  - Pencarian titik terdekat yang aman
  - Warning kuning di Output kalau gagal
- Radius cek ruang dihitung dari `size_scale`, jadi boss besar otomatis butuh tempat lebih lega
- Kalau Scale boss dinaikkan, **Attack Range ikut dinaikkan** (kira-kira 1.2 x scale)

### Kamera: anti tertutup

- **`camera_follow.gd`** lengkap sekarang punya grup `Anti Tertutup`, dengan tombol `use_pull_in` (default **false**). Kamera ditarik maju lewat `cast_motion` hanya kalau dinyalakan. Dimatikan karena zoom saat tertutup terasa aneh, dan rumah, peti, serta altar boleh menutupi hero
- **`occlusion_fader.gd`** (node `OcclusionFader`, tipe Node):
  - `roots` bertipe `Array[Node3D]`, jadi tinggal drag dari panel Scene
  - Membuat salinan material per mesh, mengubahnya ke mode alpha, lalu mengembalikan material asli setelah tidak menutupi
  - Deteksi dua tahap: AABB sebagai saringan kasar, lalu **silinder tegak di sumbu pohon** (`radius_factor`, `min_radius`, `end_fraction`, `sample_step`), supaya pohon di depan yang tidak menghalangi hero tidak ikut transparan
  - Output mencetak `[OcclusionFader] mesh terdaftar: N`
- Roots diisi hanya benda yang boleh transparan: `TressHero` dan folder pohon scatter. **Jangan** isi Hut, ChestPedestal, Altar, Ground, OuterGround, dan Cliffs
- Error `Set roots` (tipe `NodePath` vs `Node3D`): lepas skrip lalu pasang ulang, atau Reload Saved Scene, atau buat ulang node

### Kegelapan tepi peta (`OuterDarkness`)

- `MeshInstance3D` dengan QuadMesh (Size 2x2, Extra Cull Margin 16384) dan ShaderMaterial `outer_darkness.gdshader`
- Cara kerja: post-process berbasis depth, menghitung posisi dunia tiap piksel lalu menggelapkan yang berada di luar kotak arena
- Perkembangan:
  1. Versi awal terlalu hitam
  2. Dua warna: `mist_color` ungu-abu di dekat, `deep_color` biru-ungu gelap di jauh
  3. **Garis vertikal** disebabkan presisi depth di jarak jauh dan pola `sin` frekuensi tinggi. Diperbaiki dengan pola frekuensi rendah dan **Camera Near 0.5, Far 80**
  4. Gelap bertahap: kabut ungu di dekat pohon pertama, paling gelap di ujung (`end_dark`)
  5. **Langit dikecualikan** (`depth >= 0.9999` berarti `ALPHA = 0`), plus pemudar berdasarkan tinggi (`fade_start`, `fade_end`, `top_strength`)
- Nilai awal yang disarankan: `max_dark` 0.65, `mist_color` `#4a3f5e`, `deep_color` `#14142a`, `fade_width` 18, `half_size` 9.5
- Hasil terakhir dilaporkan **"udah bagus"** ✅ (sebelum tahap pengecualian langit)

### Pita hitam di horizon (saran terakhir, belum dikonfirmasi)

- Penyebab: bagian bawah langit procedural (warna ground) terlihat di luar ujung `OuterGround`
- Saran: atur `Ground Bottom Color` `#101022`, `Ground Horizon Color` `#1c1a33`, `Ground Curve` 0.02, `Sky Horizon Color` `#8a7aa0`, `Sky Curve` 0.12
- Fog: Light Color `#3a3350`, Density 0.01 sampai 0.02, Sky Affect 0.2
- Cadangan: perbesar `OuterGround` ke 200x200 dengan UV1 Scale sekitar 150
- Garis kotak ungu di horizon kemungkinan wireframe collision, matikan **Debug > Visible Collision Shapes**

---

## ⚠️ Perlu Dicek atau Diputuskan

1. **`goblin_frames` belum jadi**: 32 animasi x 3 jenis. Skrip `@tool` pembangunnya belum ditulis karena masih menunggu info sheet (ukuran satu frame, ukuran PNG, urutan baris arah, dan apakah sheet lv2 dan boss beda ukuran)
2. **`ACTION_OFFSETS`** di `goblin.gd` masih `Vector2(0, 0)`. Isi dengan angka offset kaki yang lama kalau perlu
3. Posisi spawn belum dicocokkan dengan tebing dan pohon. Kalau ada warning "tidak ada titik aman", geser angkanya (contoh boss ke (-5, 0, 3))
4. Goblin lama yang ditaruh manual di peta harus sudah dihapus supaya tidak dobel dengan spawner
5. Detect Range Lv1 dan boss sengaja 5, karena hero spawn di (0, 0, 8)
6. **Camera Far 80** bisa memotong benda jauh. Kalau ada yang terpotong, naikkan sedikit (Near ke 0.3 kalau benda dekat kamera terpotong)
7. **Collision Hut** belum terkonfirmasi. Hanya relevan kalau `use_pull_in` dinyalakan lagi
8. OcclusionFader: kalau masih ada pohon yang ikut hilang padahal tidak menutupi, turunkan `radius_factor` (0.25). Kalau pohon yang menutupi tidak transparan, naikkan (0.5). Belum ada konfirmasi hasil terakhir
9. Efek `OuterDarkness` dan fix horizon belum dikonfirmasi dari kamera game setelah langit dikecualikan

---

## 📌 Belum Dikerjakan

### Goblin dan pertarungan
- [ ] Skrip `@tool` pembangun `goblin_frames.tres` (butuh info sheet di atas)
- [ ] Buat tiga file frames dan isi di tiga file stats
- [ ] **Hero `take_damage`**, HP, kebal 0.6 s setelah kena
- [ ] **Hero menyerang** (tombol J, cooldown 0.5 s, jangkauan 1.3 m) agar `take_damage` goblin terpakai
- [ ] Drop item dan efek kematian
- [ ] Slime hijau (Level 1) dan varian slime lain
- [ ] Atur **Collision Layer** sesuai GDD 6.7 (World, Player, Enemy). Sekarang semua layer 1, jadi hero dan goblin saling dorong
- [ ] `level_1.tscn` membungkus `map_a.tscn`

### Atmosfer
- [ ] Atur WorldEnvironment mengikuti referensi: fog ungu, ambient hangat, warna langit senja
- [ ] `SunRays`, kunang-kunang, vignette
- [ ] Turunkan shadow ke 2 splits untuk web
- [ ] Cek FPS dan tampilan `OuterDarkness` di browser (shader depth-based belum dicoba di ekspor web)

### Sisa dari Doc 6
- [ ] Collision batu scatter, Hut, ChestPedestal, batu altar, dan pohon di tanah
- [ ] Visual peta: batang raksasa, lumut kaki tebing, landmark (Batch 1), gubuk asli, halaman gubuk, pemecah ruang, clutter, lingkaran rune, pohon `Far`, tekstur lantai natural
- [ ] **CREDITS.md**: Kenney, ambientCG Bark014, aset hero dan Orc
- [ ] Menu pause dan tombol fullscreen untuk versi web
- [ ] Update GDD: kamera (pitch dan yaw baru), ukuran peta 18x18, bayangan, sprite 4 arah goblin, sistem stats goblin, day-night cycle

---

## 🧭 Keputusan yang Sudah Disepakati

- Satu `goblin.tscn` dengan stats dalam Resource. Beda level hanya di damage dan kecepatan (plus HP, ukuran, dan sprite)
- Spawn goblin dilakukan lewat kode di `enemy_spawner.gd`
- Rumah, peti, dan altar **boleh menutupi** hero. Hanya pohon yang transparan
- Langit tidak ikut gelap. Kegelapan tepi peta hanya di benda berpermukaan dan pudar ke atas
- Gelap hutan bukan hitam, tapi ungu-biru berkabut yang makin gelap di ujung

---

## 🚀 Langkah Berikutnya yang Disarankan

1. Kirim info sheet goblin (ukuran frame, ukuran PNG, urutan baris arah) lalu bikin skrip pembangun `goblin_frames.tres`
2. Konfirmasi fix horizon dan langit dari kamera game
3. Tes spawner dan semua state goblin (idle, wander, chase, attack, hurt, death)
4. Hero `take_damage` dan serangan hero (tombol J)
5. Collision layer sesuai GDD

Mau lanjut yang mana?