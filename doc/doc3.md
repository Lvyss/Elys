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
