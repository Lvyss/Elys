# Rekap Proyek Godot, Doc 4 (Aset, Material, Cahaya, dan Ekspor Web)

## ✅ Yang Sudah Jadi di Sesi Ini

### Keputusan arah visual
- Target: **area semi-realistik, karakter tetap pixel** (HD-2D), dengan referensi gambar hutan berkabut, sinar matahari, gubuk, altar rune, dan banyak clutter
- Penentu "realistik" (urut dari terbesar): **tekstur, cahaya dan atmosfer, detail kecil di permukaan, bentuk model, post-processing**. Model low-poly boleh asal teksturnya kaya
- Pendekatan aset: model dasar dari **Kenney Nature Kit** (CC0, format GLTF/glb), lalu di-**retexture** dengan tekstur CC0 dari **ambientCG**
- Ukuran peta **tetap 18x18**, tidak diperbesar. Yang dikejar adalah kepadatan di area yang terlihat kamera, bukan luas peta

### Aset dan material
- Nature Kit terunduh, isi folder GLTF disalin ke `assets/` (folder aset di project: Goblin, Hero, Keney, Lainya, Materials, Shader)
- Tunggul pohon (`stump`) dipasang di peta sebagai `StaticBody3D` + model glb + collision silinder
- Material `bark_mat.tres` (tekstur Bark014 dari ambientCG, dikecilkan jadi **256 px**):
  - Albedo (Color), **Normal Map** (`_NormalGL`), **Roughness Map**
  - Triplanar dipakai karena model Kenney memakai tekstur palet kecil, jadi UV-nya tidak cocok untuk tekstur kayu biasa
  - UV scale dikecilkan dan Normal Strength diturunkan supaya tidak terlihat seperti lumpur

### Cahaya dan atmosfer
- Struktur node: folder `Lighting` berisi `DirectionalLight3D`, `WorldEnvironment`, dan `DayNightManager`
- `DirectionalLight3D` nyasar di dalam aset tunggul sudah dihapus, tersisa satu matahari utama
- Shadow aktif, tonemap **ACES**, glow, procedural sky (warna atas dan horizon diatur)
- **Fog biasa aktif dan tampil**
- `DayNightManager` (GDScript): matahari berputar otomatis, warna cahaya dari Gradient (pagi biru dingin, siang putih, sore jingga), ketebalan kabut dari Curve

### Renderer dan ekspor web
- Terkonfirmasi lewat Output editor: **Godot 4.7.2, renderer Compatibility (OpenGL 3.3)**
- **SSAO, SDFGI, Volumetric Fog tidak berefek** di Compatibility (sudah dicoba, memang tidak ada efeknya). Fog biasa yang berfungsi
- Dokumentasi resmi: Godot 4 hanya menarget WebGL 2.0 lewat Compatibility, dan Forward+/Mobile belum bisa ke web (belum ada WebGPU). Jadi **jangan ganti ke Forward+**
- Export template 4.7.2 dipasang lewat Manage Export Templates
- Preset **Web (Runnable)** dibuat, ekspor single-thread (Thread Support mati), hasilnya `index.html`, `index.pck` (30,4 MB), `index.wasm` (36,1 MB), dan file pendukung
- Masalah "Failed to fetch": penyebabnya file dibuka langsung dari folder (alamat `C:/...`). Solusi: **jalankan lewat XAMPP Apache**, folder `C:\xampp\htdocs\web\`, buka `http://localhost/web/`
- **Game web sudah berhasil terbuka dan jalan** ✅

---

## ⚠️ Beda dari GDD atau Rekap Sebelumnya (catat atau putuskan)

1. **Efek SSAO, SDFGI, Volumetric Fog**: tidak jalan di Compatibility. Matikan centangnya, dan pakai pengganti (fog biasa, plane sinar matahari, ambient hangat)
2. **Aset lingkungan**: bukan lagi kotak primitif. Sekarang model Kenney + retexture (GDD 7.4 "pack low-poly + retexture"). Update GDD 7.4
3. **Sumber aset baru**: Kenney Nature Kit, ambientCG. Belum dicatat di `CREDITS.md`
4. **Day-night cycle**: fitur baru di luar GDD, siklus pagi sampai sore. Putuskan dipertahankan atau tidak, dan apakah level 3 (fajar) memakainya
5. **Skala landmark**: disarankan 1.3x sampai 1.6x dari ukuran realistis supaya terasa penuh seperti diorama referensi. Belum diterapkan
6. **Rangkuman sesi sebelumnya (dari Gemini)** menyebut SSAO/SDFGI/volumetric sebagai efek yang aktif. Itu keliru untuk project ini, abaikan bagian itu

---

## 📌 Belum Dikerjakan / Belum Dikonfirmasi

### Dari sesi ini
- [ ] **Matikan** centang SSAO, SDFGI, Volumetric Fog di WorldEnvironment
- [ ] **Tuning fog** ala referensi (nilai awal diberikan: warna `#8b7a99`, Density 0.02, Height 1.5, Height Density 0.3). Belum dikonfirmasi hasilnya
- [ ] **Sinar matahari palsu**: `SunRays` berisi 4 plane (Quad) dengan material Unshaded, Blend Add, Cull Disabled, tekstur GradientTexture2D. Panduan sudah diberikan, belum ada konfirmasi
- [ ] **Turunkan beban shadow untuk web**: Directional Shadow ke 2 splits dan Max Distance sekitar 30 sampai 40 (sekarang 4 splits)
- [ ] **Cek performa di browser**: FPS, tekstur dan bayangan tampil, error di F12 > Console. Belum dilaporkan
- [ ] **Material** untuk batu (Rock), lumut (Moss), tanah, dan kayu papan. Cuma kayu yang sudah jadi
- [ ] **Lantai**: masih hijau terang dan pixelated. Ganti ke tekstur rumput natural (tileable, kecilkan ke 256 sampai 512 px)

### Rencana aset (urut prioritas, koordinat dari Doc 3b)
- [ ] **Batch 1, siluet besar**: 3 batu altar (`stone_tall*`, Scale Y 1.5 sampai 1.8), peti + alas dua tingkat di (-6, 0, -6), formasi batu belakang peti, tunggul ke-2 di (7.8, 0, -2)
- [ ] **Batch 2, halaman gubuk** (Z -6 sampai -4): tong, kotak, tumpukan kayu, api unggun, pagar. Sumber: Kenney Survival Kit, Fantasy Town Kit
- [ ] **Batch 3**: batang tumbang (-7.5, 0, 4.5), pagar pemandu kiri dan kanan jalan di selatan (tinggi di bawah 1 m)
- [ ] **Batch 4, clutter** pakai `scatter.gd`: MeadowGrass, MeadowFlowers, FernRight, Mushrooms, NorthRocks, NorthFerns. Cast Shadow dimatikan, tanpa collision
- [ ] **Gubuk**: masih kotak placeholder, retexture dulu, cari model asli nanti
- [ ] **Efek rune menyala** (emission) untuk batu altar
- [ ] **Kredit**: tambahkan Nature Kit (Kenney, CC0), Bark014 (ambientCG, CC0), dan pack berikutnya ke `CREDITS.md`
- [ ] **Perkecil tekstur** semua aset baru ke maksimal 512 px

### Ekspor dan struktur
- [ ] Atur **Export Path** langsung ke `C:\xampp\htdocs\web\index.html`, hapus file `.import` yang ikut tersalin
- [ ] Alternatif: `.gdignore` di folder `build` supaya Godot tidak meng-import hasil ekspor
- [ ] Siapkan `.htaccess` (`AddType application/wasm .wasm`) kalau muncul error MIME
- [ ] Tiap ekspor ulang: salin atau ekspor langsung, lalu **Ctrl + F5** di browser
- [ ] Web: `quit()` tidak menutup tab dan fullscreen butuh aksi pemain. Perlu menu pause dan tombol fullscreen (sisa Doc 3)

### Sisa dari Doc 1 sampai 3
- [ ] Dinding tak terlihat dan collision landmark (Hut, ChestPedestal, batu altar)
- [ ] Collision pohon dan batu hasil scatter
- [ ] Collision layer sesuai GDD 6.7, group `enemy`
- [ ] Goblin sesuai statistik GDD (HP 40, damage 10, kecepatan 3.0, deteksi 8 m), mengejar dan menyerang hero
- [ ] Serang hero (tombol J), HP, kebal setelah kena, slime
- [ ] `level_1.tscn` membungkus `map_a.tscn`
- [ ] Pohon bisa menutupi kamera (kamera orbit 360°), pertimbangkan transparan saat menghalangi hero
- [ ] Kunang-kunang dan vignette

---

## 🧭 Aturan Pasang Aset (alur yang sama untuk semua)
1. Unduh pack CC0, salin glb ke folder `assets/`
2. Drag glb ke node `StaticBody3D` di bawah `Props`
3. Atur Position, Rotation Y acak, Scale di node glb (anak), bukan di `StaticBody3D`
4. Tambah `CollisionShape3D` sederhana (silinder atau kotak) untuk objek besar
5. Retexture lewat **Geometry > Material Override** (`Editable Children` diaktifkan)
6. Catat di `CREDITS.md`

## 🚀 Langkah Berikutnya yang Disarankan
1. Rapikan WorldEnvironment (matikan 3 efek, tuning fog), lalu turunkan shadow ke 2 splits
2. Kerjakan **Batch 1** (batu altar dulu, paling gampang)
3. Sinar matahari palsu
4. Ekspor ulang, cek FPS dan tampilan di browser

Mau lanjut yang mana?