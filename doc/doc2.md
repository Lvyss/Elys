# Rekap Proyek Godot, Doc 2 (Fokus Peta A)

## ✅ Yang Sudah Jadi di Sesi Ini

### Lantai (`map_a.tscn`)
- `Ground` PlaneMesh diperkecil dari 25x25 jadi **18x18**
- Material diganti ke **ShaderMaterial** (rumput + tanah + mask jalan)
- Tiga tekstur terpasang: `grass_tile.png`, `dirt_tile.png`, `path_mask.png`
- Hasil: lantai rumput dengan jalan tanah bercabang sesuai gambar denah, arah mask sudah benar (tidak perlu di-flip)
- Masalah awal "shader parameter tidak muncul" sudah teratasi, karena lantai sekarang tampil benar

### Landmark (placeholder dari kotak)
- **Hut** di (5, 0, -7): dinding, atap prisma, pintu, jendela emisi oranye
- **ChestPedestal** di (-6, 0, -6): alas batu + peti
- **Altar** (Node3D di 0,0,0) berisi **3 batu** melengkung: Stone1 (-7, 0.7, 1.4), Stone2 (-5.5, 0.7, 0.4), Stone3 (-4, 0.7, 1.4)
- Keputusan: objek tetap kotak sederhana dulu, aset bagus dicari belakangan

### Hero dipasang lagi
- `player.tscn` kembali di peta, spawn di (0, 0, 8)
- Goblin masih dilepas dari peta (file scene aman)

### Kamera baru (perspektif miring)
- Rotation **(-26, 20, 0)**, Position **(3.1, 5.4, 16.5)**, FOV tetap **30**
- Dihitung dengan rumus offset: posisi kamera = titik target + (D·cos P·sin Yaw, D·sin P, D·cos P·cos Yaw), dengan D = 10 dan target (0, 1, 8)
- Kesalahan sebelumnya: Z kamera masih 8.0 padahal seharusnya sekitar 16. Sudah diperbaiki dan hero kembali di tengah layar
- Hero harus ada di spawn saat kamera diatur, karena `camera_follow.gd` mengingat jarak dari posisi editor

---

## ⚠️ Beda dari GDD (catat atau putuskan)

1. **Ukuran peta**: GDD/rekap awal 25x25, sekarang **18x18**.
2. **Kamera**: GDD 35°, sekarang **pitch -26° dan yaw 20°**. Yaw baru, GDD belum menyebutnya sama sekali.
3. **Landmark**: masih kotak placeholder. Perlu diputuskan nanti memakai Kenney Nature Kit atau gaya primitif.
4. **Struktur node**: pembagian Ground, Landmarks, Boundary, Props, Details, Lighting dianjurkan, tapi belum dipastikan sudah dirapikan semua.

---

## 📌 Belum Dikerjakan / Belum Dikonfirmasi

Tahap 4 sampai 6 sudah diberikan panduannya, tetapi belum ada konfirmasi hasilnya. Cek satu per satu:

- [ ] **Dinding tak terlihat** (`Walls` StaticBody3D, 4 CollisionShape3D) di tepi 18x18
- [ ] **Collision landmark**: Hut, ChestPedestal, 3 batu altar
- [ ] **Cahaya**: DirectionalLight3D (Energy 1.1, Shadow Blur 1.5), WorldEnvironment (hijau gelap, fog, contrast 1.1, saturation 1.15), OmniLight di gubuk
- [ ] **Batas kamera** (`use_limits`), perlu disesuaikan ulang karena kamera sekarang bergeser ke samping
- [ ] **Kontrol WASD**: dengan yaw 20°, arah "atas" di keyboard jadi agak diagonal di layar. Kalau mengganggu, putar vektor gerak di `player.gd` mengikuti yaw kamera
- [ ] **Pohon placeholder di tepi** (utara, kiri, kanan). Tepi selatan hanya semak atau pagar pendek supaya tidak menutupi hero
- [ ] **Aset**: cari Kenney Nature Kit atau pack CC0 lain, lalu ganti kotak-kotak. Catat di `CREDITS.md`
- [ ] **Skrip `scatter.gd`** untuk menyebar pohon, batu, dan semak
- [ ] **Efek lanjutan**: sinar matahari, kunang-kunang, vignette
- [ ] **Uji ekspor web** (belum pernah dicoba)
- [ ] Sisa dari Doc 1 yang belum berubah: collision layer, group `enemy`, serang hero, statistik goblin sesuai GDD, `level_1.tscn`

---

## 🧭 Keputusan Desain yang Sudah Disepakati

- Slime tetap ada, sehingga **GDD tidak perlu diubah** untuk bagian slime, item, dan teka-teki
- Pembagian musuh per level: **L1** slime hijau, **L2** goblin + slime hijau, **L3** goblin + slime hijau dan biru
- Varian goblin (Rogue, Mage) hanya **bonus**, kelas dasar `Enemy` dengan method `attack()` yang di-override
- Altar ada dari awal. Fajar di Level 3 hanya perubahan angka cahaya, fog, dan ambient
- Fokus sekarang: **map dulu**, hero dan musuh menyusul

---

## 🚀 Langkah Berikutnya yang Disarankan

1. Konfirmasi Tahap 4 (dinding dan collision) dan Tahap 5 (cahaya), lalu kirim screenshot.
2. Pohon dan semak placeholder di tepi supaya map tidak kosong.
3. Cari aset 3D, lalu ganti placeholder.
4. Setelah itu uji ekspor web satu kali, lalu kembali ke goblin dan serang hero.

Mau lanjut ke yang mana?