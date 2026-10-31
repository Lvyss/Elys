# Rekap Proyek Godot, Doc 5 (Tebing, Pohon, dan Collision)

## ✅ Yang Sudah Jadi di Sesi Ini

### Arah penataan peta

- Peta masih **18x18**, kamu menata **tebing dan pohon secara manual** sesuai gambar referensi (ukuran dan posisi tidak mengikuti tabel koordinat dari aku)
- Pembagian yang disepakati: **manual untuk yang kelihatan kamera** (pohon hero, di bingkai, dekat gubuk dan altar), **random (`scatter.gd`)** untuk hutan jauh yang tertelan kabut
- Pohon `Far` (lapisan hutan jauh) **ditunda**
- Kamu menemukan bahwa referensi punya **tebing berlapis di pinggir peta**, dan petamu sebelumnya datar. Tebing dipasang dari **Kenney (blok `block-grass-...`, `overhang`, `slope`, `corner`)**, sebagai placeholder
- Pohon besar (`TreeBig`) dipasang manual di folder **`TressHero`** (19 pohon), sebagian di tanah, sebagian di atas tebing

### Hero: dari Floating ke Grounded

- Rencana ada **jump**, jadi `Motion Mode` diganti ke **Grounded**
- Tambah di `player.gd`: `GRAVITY := 20.0`, `JUMP_VELOCITY := 7.0`, cek `is_on_floor()`, dan action **`jump`** di Input Map
- `player.gd` sudah memakai `move_and_slide()` dengan arah gerak mengikuti kamera

### Collision lantai (sudah beres)

- Masalahnya: `CollisionShape3D` berdiri sendiri tanpa `StaticBody3D` (muncul **warning kuning**), jadi hero jatuh
- Perbaikan: `CollisionShape3D` dipindah ke dalam `StaticBody3D` (BoxShape3D 18 x 1 x 18, posisi (0, -0.5, 0)). **Hero sekarang berdiri di tanah** ✅

### Skrip collision otomatis

Dua skrip `@tool` di folder `scripts`, dengan tombol di Inspector (`@export_tool_button`, Godot 4.4+):

| Skrip                     | Dipakai di                         | Fungsi                                                                                                                                         |
| ------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `auto_collision.gd`       | `Cliffs` (dan folder batu scatter) | Buat `StaticBody3D` bernama `AutoCol_<nama>` per objek, bentuk **Convex** dari mesh, dengan scale dan rotasi sudah dihitung ke titik bentuknya |
| `auto_collision_trunk.gd` | `TressHero`                        | Buat `TrunkCol_<nama>` hanya untuk **bagian bawah batang**                                                                                     |

**Hasil:**

- **Collision tebing sudah jalan** ✅ (bentuknya kotak dominan, cocok dengan Convex)
- **Collision pohon**: skrip sekarang mengukur radius dasar batang sendiri, memotong di `cut_fraction` (default 0.25 dari tinggi), dan membuang titik cabang di luar radius. Output menunjukkan 76 dari 416 titik dipakai per pohon, radius dasar 0.65 sampai 1.46. Kamu bilang hasilnya sudah **enak** ✅

### Masalah yang sempat muncul dan solusinya

1. **"Collision dibuat untuk 0 mesh"**: blok tebing adalah instance `.glb`, jadi mesh tersembunyi. Solusi: `get_children(true)`
2. **Hero tembus tebing**: scale non-uniform pada collision. Solusi: titik bentuk dikalikan transform, body ditaruh di `Cliffs` tanpa scale
3. **Error `collision_layer ... Nil`**: variabel export belum terisi di `@tool`. Solusi: angka langsung `= 1`
4. **Checkbox Generate tidak muncul**: ganti ke `@export_tool_button`
5. **Collision pohon melebar**: convex dari seluruh mesh ikut tajuk dan cabang. Solusi: ambil titik bagian bawah dan filter radius
6. **Silinder terlalu kecil dan terbenam**: batang kamu kotak melebar di bawah, jadi dipakai bentuk mesh asli, bukan silinder
7. **Skrip lama masih tersangkut di Inspector** (`Set trunk_radius`): lepas lalu pasang ulang skrip, atau **Scene > Reload Saved Scene**

---

## ⚠️ Perlu Dicek atau Diputuskan

1. **Scene tersimpan?** Pastikan **Ctrl+S** setelah Generate, lalu Play ulang
2. **Sisa `AutoCol_...` di folder pohon**: pastikan `TressHero` hanya berisi `TrunkCol_...`
3. **Jangan Regenerate scatter** setelah collision dibuat. Objek lama dihapus dan collision ikut hilang. Kalau terpaksa, klik Generate collision lagi
4. **Folder skrip harus Node3D dengan Scale (1,1,1)** dan objek sebagai **anak langsung**
5. **Hero bisa melompati atau naik tebing rendah** sekarang setelah ada jump. Cek tinggi collision tebing (disarankan di atas 2 m)
6. **Dinding tak terlihat** (4 sisi, tinggi 4 m) dari Doc 3b: belum terkonfirmasi sudah dibuat
7. **Performa collision convex di web**: kalau ada lag, ganti ke BoxShape3D sederhana

---

## 📌 Belum Dikerjakan

### Collision (lanjutan)

- [ ] **Batu scatter dekat jalan** (`RocksSouthWest`, `RocksSouthEast`, dst.): tempel `auto_collision.gd`, klik Generate
- [ ] **Collision Hut, ChestPedestal, 3 batu altar**
- [ ] **Collision pohon lain di tanah** (folder scatter dekat jalan), pakai skrip trunk
- [ ] Atur **Collision Layer** sesuai GDD 6.7 (sekarang semua layer 1)

### Visual peta (urutan dari besar ke kecil, sesuai rencanamu)

- [ ] **Tahap 1B**: batang raksasa `trunk.tscn` di bingkai kiri-kanan depan
- [ ] **Lumut dan batu besar di kaki tebing** supaya sambungan ke tanah tidak keras
- [ ] **Landmark (Batch 1)**: batu altar tinggi, peti di alas dua tingkat, formasi batu di belakang peti, tunggul ke-2
- [ ] **Gubuk**: ganti kotak dengan model asli (Kenney Fantasy Town atau Survival Kit)
- [ ] **Halaman gubuk (Batch 2)**: tong, kotak, kayu bakar, rak gantung, lampion
- [ ] **Pemecah ruang (Batch 3)**: batang tumbang, pagar pendek di kiri-kanan jalan selatan
- [ ] **Clutter (Batch 4)** dengan `scatter.gd` (pakai **MultiMesh** untuk web): rumput tinggi, bunga, pakis, jamur
- [ ] **Lingkaran rune**: Quad transparan di Y 0.02 (Decal tidak jalan di Compatibility)
- [ ] **Pohon hutan jauh (`Far`)**
- [ ] **Lantai**: masih hijau terang, ganti ke tekstur rumput natural dan turunkan saturasi

### Sisa dari Doc 1 sampai 4

- [ ] **Bayangan karakter**: tidak ada node terpisah, cast shadow dari sprite (`AnimatedSprite3D > Cast Shadow`) + Shadow di DirectionalLight3D. Tinggal dicek kalau tidak muncul
- [ ] Tuning WorldEnvironment (matikan SSAO, SDFGI, Volumetric Fog), fog ala referensi
- [ ] Turunkan shadow ke 2 splits untuk web, `SunRays`, kunang-kunang, vignette
- [ ] Material batu, lumut, dan tanah
- [ ] **CREDITS.md**: Kenney Nature Kit dan blok tebing, ambientCG Bark014, aset hero dan Orc
- [ ] Goblin sesuai GDD (HP 40, damage 10, kecepatan 3.0, deteksi 8 m), serang hero (J), HP, slime
- [ ] `level_1.tscn`, group `enemy`
- [ ] Pohon menutupi kamera (transparan saat menghalangi hero)
- [ ] Ekspor web ulang, cek FPS, **menu pause dan tombol fullscreen** untuk versi web

---

## 🚀 Langkah Berikutnya yang Disarankan

1. Simpan scene (**Ctrl+S**), lalu tes semua collision dengan **Visible Collision Shapes**
2. Collision **batu scatter** dekat jalan, lalu **Hut, ChestPedestal, batu altar**
3. Lanjut menata visual: **batang raksasa, lumut kaki tebing, landmark**
4. Setelah peta terasa penuh, kembali ke **goblin dan serang hero**

Mau lanjut yang mana?
