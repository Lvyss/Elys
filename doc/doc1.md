# Rekap Proyek Godot

Oke, ini rekapnya langsung teks.

## ✅ Yang Sudah Jadi

### Project

- Godot 4.3+
- Renderer: **Compatibility**
- Default Texture Filter: **Nearest**
- Input map: `left/right/up/down` (WASD + panah)

### Peta (`map_a.tscn`)

- Tanah: `PlaneMesh` 25x25
- `Camera3D`
- `DirectionalLight3D` dengan shadow
- `WorldEnvironment`: warna latar, ambient, fog, tonemap **Filmic**
- Dua pohon placeholder (silinder + bola)

### Hero (`player.tscn`)

- `CharacterBody3D` mode **Floating**
- Collision kapsul
- `AnimatedSprite3D`: Y-Billboard, Nearest, Alpha Cut Discard, Shaded, pixel size `0.02`
- Skrip `player.gd`:
  - Gerak 8 arah dengan kecepatan `4.5`
  - Animasi idle dan walk
  - Empat arah hadap: **down**, **up**, **side**
  - Side memakai `flip_h`

### Kamera

- `camera_follow.gd`
- Mengikuti hero dengan halus (lerp)
- Jarak awal diingat dari posisi di editor
- Batas kamera bisa dinyalakan

### Goblin (`goblin.tscn`)

- `CharacterBody3D`
- Sprite **Orc - Base** sebagai pengganti
- Animasi: idle, run, dan death (death belum dipakai)
- Skrip `goblin.gd`:
  - Jalan-jalan acak di sekitar titik spawn
  - Diam 1 sampai 3 detik di antaranya
  - Ada offset per animasi untuk menyamakan posisi kaki

---

## ⚠️ Beda dari GDD (perlu diputuskan atau update di GDD)

1. **Bayangan**  
   GDD 6.3 menyebut bayangan blob untuk ambient occlusion. Sempat disarankan, tetapi dipilih **cast shadow dari sprite** karena hasilnya lebih bagus. Kalau dipertahankan, catat di GDD bahwa blob diganti cast shadow.

2. **Kamera**  
   GDD menulis miring sekitar **35 derajat**. Sekarang **-28 derajat** dan jaraknya sekitar **2x lebih dekat** (posisi kira-kira `0, 4.5, 8.5`). FOV tetap **30**. Ini keputusan untuk update angka di GDD 6.3.

3. **Skala Y sprite**  
   Skala Y sprite `1.22` (kompensasi kemiringan kamera, GDD 6.3) tidak dipakai. Dengan -28 derajat kompensasinya sekitar `1.13`, jadi memang kecil dampaknya. Catat sebagai keputusan sadar.

4. **Ukuran sprite**  
   GDD 7.4 menyebut sprite sheet `48x48`. Aset aslinya campur (ada frame `32 px` dan `64 px`). Ditangani dengan offset per animasi di skrip. Update GDD 7.4.

5. **Arah sprite**  
   Hero 4 arah, goblin hanya samping. Gerak tetap 8 arah, tetapi animasi memakai **3 hadap + flip**. Sejalan dengan uji F05 di GDD, tinggal dicatat.

6. **Sprite goblin**  
   Goblin sementara memakai **Orc - Base**, bukan sprite goblin. GDD menyebut satu creator untuk hero, goblin, dan slime. Pastikan nanti stylenya cocok, dan catat sumbernya.

7. **Lingkungan**  
   Masih pakai bentuk primitif (silinder dan bola), belum model low-poly dari pack seperti di GDD 7.4. Itu boleh, tetapi putuskan nanti mau pakai pack atau tetap gaya primitif.

---

## 📌 Belum Dikerjakan (supaya tidak lupa)

- [ ] **CREDITS.md**: catat nama pembuat, lisensi, link, dan tanggal unduh untuk aset hero dan Orc (wajib di GDD 7.4 dan 8.4).
- [ ] **Collision layer** sesuai GDD 6.7 (World 1, Player 2, Enemy 3, dst). Sekarang semua masih layer default, jadi hero dan goblin saling dorong.
- [ ] **Collision untuk pohon dan dinding tak terlihat** di tepi arena. Hero masih bisa jalan keluar tanah.
- [ ] **Group `enemy`** untuk goblin (group `player` sudah dipakai kamera).
- [ ] **Goblin sesuai statistik GDD**: HP 40, damage 10, kecepatan 3.0, deteksi 8 m, kedip merah 0.4 s sebelum mengayun. Sekarang masih jalan-jalan saja, kecepatan 1.5.
- [ ] **Serang hero** (tombol `J`, cooldown 0.5 s, jangkauan 1.3 m), HP, kebal 0.6 s setelah kena, animasi mati dan drop item.
- [ ] **Struktur scene level** (`level_1.tscn` membungkus `map_a.tscn`). Sekarang hero dan goblin masih langsung ditaruh di peta.
- [ ] **Efek visual lanjutan dari GDD 6.3**: plane kabut bergerak, sinar matahari, partikel kunang-kunang, tilt-shift, rumput. Yang tilt-shift dan rumput termasuk opsional di GDD.
- [ ] **Uji ekspor web sedini mungkin** (GDD 6.1 menekankan ini). Belum dicoba sama sekali.

---

## 🚀 Langkah Berikutnya yang Disarankan

1. Goblin mengejar hero kalau dekat.
2. Serang `J` dan HP.
3. Slime.

Mau lanjut yang mana? Aku juga sarankan uji ekspor web satu kali dalam waktu dekat, supaya kalau ada efek yang tidak jalan di browser ketahuan lebih awal.
