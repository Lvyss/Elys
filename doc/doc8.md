# REKAP PROYEK GAME ELYS

> Rekap pengembangan game ELYS: aset karakter, identitas visual, environment, UI, implementasi Godot, dokumentasi, keputusan desain, dan pekerjaan lanjutan.

## 1. Gambaran Umum

**ELYS** adalah proyek fantasy RPG dengan identitas *ancient magical fantasy*. Arah visual menggabungkan karakter pixel art dengan environment painterly fantasy, UI medieval magical, serta suasana enchanted cinematic fantasy.

Fokus proyek:
- Karakter dan animasi pixel art.
- Environment hutan fantasi.
- Logo dan emblem ELYS.
- Home screen dan loading screen.
- UI button.
- Implementasi gameplay di Godot.
- Dokumentasi game untuk kebutuhan HKI.

---

## 2. Aset Karakter dan Animasi

### A. Elderly Fantasy Alchemist

Identitas:
- Topi lebar dan runcing.
- Jubah berlapis hijau dan cokelat.
- Belt, boots, dan detail bahu.
- Memegang potion bottle dengan cairan oranye bercahaya.
- Menghadap ke depan.

Animasi idle yang diminta:
- 8 frame.
- Spritesheet 4 kolom × 2 baris.
- Gerakan breathing ringan.
- Pergerakan kecil pada jubah, topi, dan potion.
- Frame terakhir kembali ke pose awal.

Ketentuan:
- Desain, proporsi, warna, dan aksesori dipertahankan.
- Pixel art tetap tajam.
- Background transparan.
- Ukuran setiap frame konsisten.

### B. Hooded Warrior

Karakter warrior berjubah dengan armor gelap dan cape merah dikembangkan dari spritesheet WALK DOWN.

Identitas:
- Hood gelap.
- Armor hitam dan abu-abu.
- Detail pakaian cokelat.
- Cape merah gelap.
- Senjata dan perlengkapan tetap pada posisi aslinya.
- Tampilan belakang menghadap SOUTH / DOWN.

Animasi yang diminta: WALK DOWN diubah menjadi IDLE DOWN.
- 8 frame.
- Format horizontal 8 kolom × 1 baris.
- Breathing ringan melalui bahu dan upper body.
- Hood dan cape mengikuti gerakan tubuh.
- Kaki tetap diam.
- Tidak ada gerakan berjalan atau perpindahan posisi.
- Frame 8 kembali ke pose netral frame 1.

**Catatan:** Idle harus benar-benar berbeda dari walk animation, bukan sekadar menduplikasi frame berjalan.

---

## 3. Logo dan Identitas Visual ELYS

### A. Emblem

Emblem utama berbentuk perisai melingkar dengan pedang vertikal.

Elemen:
- Pedang di bagian tengah.
- Crescent moon di bagian atas.
- Ornamen turquoise dan cyan.
- Aksen emerald green.
- Detail antique gold.
- Simbol dan magical runes.

Pekerjaan yang dilakukan:
1. Mengisolasi emblem dari background hutan.
2. Menghilangkan pohon, daun, embers, dan kabut di luar emblem.
3. Mempertahankan ornamen internal.
4. Menyiapkan PNG dengan transparansi alpha.

### B. Typography ELYS

Tulisan harus tepat: **ELYS**.

Arah visual:
- Dark fantasy RPG.
- Ancient magical lettering.
- Turquoise, cyan, emerald green, dan antique gold.
- Ornamen rune.
- Bentuk huruf elegan dan sedikit tajam.

Arah desain yang pernah dieksplorasi:
- Ancient fantasy.
- Dark fantasy.
- Celestial.
- Premium RPG.
- Minimalist fantasy.
- Medieval ornate.

**Desain yang dipilih:**
- Lettering melengkung dan khas.
- Ornamen rune kecil.
- Simbol bulan sabit.
- Simbol arcane di dalam huruf.
- Warna turquoise dan antique gold.
- Outline gelap.
- Nuansa ancient magical civilization.

Desain typography ini disukai dan harus dipertahankan. Jangan membuat ulang bentuk huruf atau mengganti ornamen tanpa diminta.

### C. File logo yang pernah dibuat

| File | Keterangan |
|---|---|
| `ELYS_logo_enhanced_transparent_4x.png` | Logo hasil upscale 4× |
| `ELYS_exact_reference_transparent_HD_4x.png` | Versi yang berfokus mempertahankan referensi |
| `ELYS_final_ultra_HD_transparent.png` | Versi Ultra HD |

Versi terakhir yang pernah dibuat:
- 6448 × 2224 px.
- PNG RGBA.
- Background transparan.
- Upscaling 4× dari file sebelumnya.

Catatan: Upscaling meningkatkan ukuran dan ketajaman visual, tetapi tidak dapat memulihkan detail yang tidak tersedia pada sumber.

---

## 4. Environment dan Background Game

### A. Arah Visual Utama

Gaya yang dipilih adalah **Enchanted Cinematic Fantasy**, dengan kualitas ilustrasi fantasy MMORPG seperti referensi TERA dan Elements of Defender.

Karakteristik:
- Painterly fantasy illustration.
- Cinematic lighting.
- Volumetric sunlight.
- Atmospheric fog.
- Emerald green dan deep teal.
- Turquoise, cyan, dan warm golden highlights.
- Vegetasi, arsitektur, dan terrain yang detail.
- Environmental storytelling.

Targetnya adalah promotional artwork MMORPG profesional, bukan screenshot 3D biasa.

### B. Elemen Environment

| Elemen | Deskripsi |
|---|---|
| Wooden cottage | Rumah kayu bergaya medieval fantasy |
| Ancient forest | Hutan tua dengan pepohonan besar |
| Treasure chest | Peti harta dengan ornamen logam |
| Rune stones | Batu kuno dengan simbol bercahaya |
| Stone pathway | Jalan setapak dari bebatuan |
| Mossy rocks | Bebatuan dengan lumut |
| Wooden fences | Pagar kayu |
| Vegetation | Rumput, bunga, jamur, dan tanaman |
| Magical particles | Partikel bercahaya |

Struktur altar pernah muncul dalam eksplorasi awal, tetapi kemudian secara eksplisit diminta untuk dihapus dari komposisi background terbaru.

### C. Eksplorasi Home Screen

Komposisi:
- Landscape 16:9.
- Logo di bagian tengah.
- Tepat dua tombol horizontal di bawah logo.
- Lingkungan menjadi framing di kiri dan kanan.
- Area tengah tetap terbaca.
- Tidak ada objek yang mengganggu logo dan tombol.

Tiga arah visual yang dieksplorasi:

**A — Enchanted Kingdom**
- Hangat dan elegan.
- Emerald vegetation.
- Golden sunlight.
- Welcoming fantasy atmosphere.

**B — Cinematic Mystical Forest**
- Lebih misterius.
- Deep forest.
- Teal mist.
- Magical lighting.

**C — Epic Fantasy Adventure**
- Lebih megah.
- Environmental framing lebih kuat.
- Dramatic lighting.
- Dunia fantasy terasa lebih luas.

### D. Eksplorasi Loading Screen

Komposisi:
- Logo di bagian tengah.
- Loading bar horizontal di bawah logo.
- Area logo relatif bersih.
- Loading bar tidak terlalu dekat dengan tepi bawah.
- Lingkungan tetap terlihat di sekelilingnya.

**Penting:** Loading bar tidak boleh ditempatkan di bagian paling bawah layar.

---

## 5. Revisi Besar Environment

### A. Forest Clearing

Konsep awal menggunakan area hutan terbuka dengan treasure chest, rune stones, cottage, pohon besar, jalan setapak, dan cahaya matahari.

### B. Ancient Mystical Sanctuary

Eksplorasi menonjolkan batu rune, struktur batu kuno, kabut mistis, cahaya cyan, dan pepohonan besar. Konsep altar kemudian tidak lagi dipertahankan.

### C. Hidden Forest Village

Konsep ini mengembangkan cottage sebagai bagian dari desa hutan, jalur batu, vegetasi lebih kaya, lingkungan yang terasa hidup, dan environmental storytelling.

### D. Arah Komposisi Terbaru: Treasure Chest Left, Interface Area Right

**Ini merupakan keputusan komposisi terbaru dan harus dijadikan acuan.**

#### Kiri — Large Treasure Chest
- Peti harta berukuran besar.
- Ornamen logam dan ukiran fantasy.
- Material kayu yang detail.
- Terintegrasi secara alami ke lingkungan hutan.
- Menjadi focal point utama sisi kiri.
- Mendapat cinematic golden lighting.

#### Kanan — Button Placement Area
- Area luas dan relatif bersih.
- Tidak ada objek besar yang mengganggu.
- Tidak ada peti harta tambahan.
- Tidak ada bangunan besar.
- Background tetap berupa lingkungan hutan.
- Kontras cukup untuk penempatan tombol.

#### Elemen pendukung
- Cottage tetap terlihat sebagai bagian dari dunia.
- Hutan menjadi lingkungan utama.
- Jalan setapak dan bebatuan menyatu dengan pemandangan.
- Rune stones boleh menjadi elemen pendukung selama tidak membentuk altar.

**Larangan untuk komposisi terbaru:**
- Tidak boleh ada altar.
- Tidak boleh ada shrine.
- Tidak boleh ada rune altar.
- Tidak boleh ada struktur pengganti yang menyerupai altar.
- Ruang bekas altar harus direkonstruksi secara alami dengan terrain, vegetasi, atau bebatuan.

File hasil terakhir yang pernah dibuat: `a_highly_detailed_fantasy_forest_concept_art_scene.png`.

Spesifikasi yang pernah dicatat:
- 1648 × 928 px.
- Landscape.
- Painterly fantasy.
- Tanpa logo, tombol, teks, atau UI.

---

## 6. Desain UI Button

UI button dikembangkan dengan tema ancient magical fantasy, seperti artefak dari dunia ELYS.

Arah visual:
- Dark metallic.
- Enchanted stone.
- Deep teal dan emerald.
- Turquoise dan cyan.
- Antique gold.
- Magical runes.
- Medieval ornamental borders.

### Delapan konsep tombol

1. Ornate rectangular fantasy button.
2. Ancient engraved stone button.
3. Dark metallic turquoise border button.
4. Elegant gold-accented magical button.
5. Minimal arcane button.
6. Crescent-moon fantasy button.
7. Emerald and cyan rune-engraved button.
8. Intricate medieval fantasy button.

Ketentuan:
- Siluet masing-masing harus berbeda.
- Border tidak boleh sama semua.
- Area tengah cukup kosong untuk teks.
- Tidak terlalu banyak efek glow.
- Tidak menggunakan gaya modern flat UI atau cyberpunk.
- Background transparan.
- Tanpa label atau tulisan.

Aset ini nantinya digunakan untuk tombol home screen, misalnya Start Game dan About.

---

## 7. Pengembangan Godot

Berdasarkan rekap teknis proyek yang telah dibahas, implementasi menggunakan Godot 4.

### A. Project Configuration

| Komponen | Pengaturan |
|---|---|
| Engine | Godot 4.3+ |
| Renderer | Compatibility |
| Default Texture Filter | Nearest |
| Input | WASD + Arrow Keys |
| Movement | 8 arah |

Input map:
- `left`
- `right`
- `up`
- `down`

### B. Main Menu

Scene utama menggunakan:
- `mainmenu`
- Start Button
- About Button
- Quit Button

Fungsi:
- Start untuk memulai permainan.
- About untuk membuka informasi game.
- Quit untuk keluar dari permainan.

### C. Map

Scene: `map_a.tscn`

Struktur:
- `PlaneMesh` ukuran 25 × 25.
- `Camera3D`.
- `DirectionalLight3D`.
- `WorldEnvironment`.
- Dua pohon placeholder menggunakan silinder dan bola.

WorldEnvironment:
- Background color.
- Ambient lighting.
- Fog.
- Filmic tonemapping.

### D. Player

Scene: `player.tscn`

Node utama:
- `CharacterBody3D`.
- Collision kapsul.
- `AnimatedSprite3D`.

Konfigurasi sprite:
- Y-Billboard.
- Nearest filtering.
- Alpha Cut Discard.
- Shaded.
- Pixel size `0.02`.

Skrip: `player.gd`

Fitur:
- Gerakan 8 arah.
- Kecepatan 4.5.
- Idle animation.
- Walk animation.
- Gerak menggunakan tiga orientasi sprite.
- Side menggunakan `flip_h`.

### E. Camera

Skrip: `camera_follow.gd`

Fitur:
- Kamera mengikuti player.
- Pergerakan halus menggunakan lerp.
- Jarak awal diingat dari editor.
- Batas kamera bisa diaktifkan.

Pengaturan:
- Rotasi sekitar -28 derajat.
- Posisi kira-kira `(0, 4.5, 8.5)`.
- FOV 30.

### F. Goblin / Enemy

Scene: `goblin.tscn`

Node:
- `CharacterBody3D`.
- Sprite sementara menggunakan Orc - Base.

Skrip: `goblin.gd`

Fitur:
- Idle.
- Run.
- Death (belum digunakan).
- Random wandering.
- Berjalan di sekitar titik spawn.
- Diam 1–3 detik.
- Offset per animasi untuk menyamakan posisi kaki.

Kecepatan wandering sementara: 1.5.

---

## 8. Dokumentasi dan Manual Book HKI

Dokumen yang pernah diminta: `MANUAK BOOK HKI-GAME ELYS.docx`.

Ketentuan:
- Bahasa Indonesia formal.
- Times New Roman 12.
- Berdasarkan GDD.
- Mengikuti struktur PDF referensi.
- Sampul putih polos tanpa tulisan, logo, atau gambar.
- Semua font hitam.
- Garis biru bawah halaman dihapus.
- Daftar isi dikosongkan.
- Minimal lima screenshot.
- Screenshot difokuskan pada lima fungsi utama.
- Source code atau placeholder disediakan jika materi belum tersedia.
- Tidak mengarang informasi yang belum ada.

Referensi tata letak: `MANUALBOOK EDUCHIEV_HKI.pdf`.

Lima placeholder screenshot yang pernah direncanakan mencakup:
- Tutorial / Gameplay Level 1.
- Tampilan permainan / HUD.
- Toko Kakek Orrin.
- Dua fungsi utama lainnya sesuai materi game yang tersedia.

---

## 9. Keputusan Desain yang Perlu Dipertahankan

| Aspek | Keputusan |
|---|---|
| Nama game | ELYS |
| Identitas visual | Ancient magical fantasy |
| Environment | Enchanted cinematic fantasy |
| Warna utama | Turquoise, emerald, gold |
| Logo | Typography ELYS yang sudah disetujui |
| Emblem | Crescent moon dan central sword |
| Karakter | Pixel art |
| Background | Painterly fantasy illustration |
| Home screen | Logo dan dua tombol horizontal |
| Loading screen | Logo dan loading bar |
| UI button | Medieval magical ornamental |
| Background terbaru | Chest kiri, interface area kanan |
| Altar | Dihapus dari komposisi terbaru |

---

## 10. Pekerjaan yang Belum Selesai

### A. Visual Assets

- [ ] Menentukan background home screen final.
- [ ] Menentukan background loading screen final.
- [ ] Menyesuaikan ukuran background ke 1920 × 1080.
- [ ] Finalisasi delapan desain UI button.
- [ ] Menentukan desain tombol Start Game dan About.
- [ ] Mengintegrasikan typography ELYS dengan background.
- [ ] Menguji keterbacaan logo di berbagai ukuran layar.
- [ ] Memastikan seluruh aset transparan benar-benar memiliki alpha channel.
- [ ] Menyiapkan aset visual final untuk implementasi Godot.

### B. Gameplay

- [ ] Sistem goblin mengejar player jika berada dalam jarak deteksi.
- [ ] Sistem serangan player menggunakan tombol J.
- [ ] Cooldown serangan 0.5 detik.
- [ ] Jangkauan serangan 1.3 meter.
- [ ] Sistem HP player.
- [ ] Sistem HP enemy.
- [ ] Invulnerability 0.6 detik setelah terkena serangan.
- [ ] Animasi damage dan death.
- [ ] Sistem drop item.
- [ ] Implementasi slime.

### C. Struktur Project

- [ ] Membuat `level_1.tscn`.
- [ ] Memisahkan map dan entity.
- [ ] Menambahkan collision layer.
- [ ] Menambahkan group `enemy`.
- [ ] Menambahkan collision untuk pohon dan batas arena.
- [ ] Menyesuaikan statistik goblin dengan GDD.
- [ ] Menambahkan CREDITS.md.
- [ ] Melakukan pengujian ekspor web.

### D. Environment

- [ ] Mengganti placeholder pohon dengan model final.
- [ ] Menambahkan rumput dan vegetasi.
- [ ] Menambahkan fog plane bergerak.
- [ ] Menambahkan sinar matahari.
- [ ] Menambahkan partikel kunang-kunang.
- [ ] Mempertimbangkan tilt-shift sesuai GDD.
- [ ] Menguji performa environment.

---

## 11. Langkah Pengembangan Berikutnya

### Tahap 1 — Finalisasi Visual Identity
1. Tetapkan logo ELYS final.
2. Tetapkan emblem.
3. Tetapkan palet warna.
4. Tetapkan desain UI button.

### Tahap 2 — Finalisasi Environment
1. Pilih background home screen.
2. Pilih background loading screen.
3. Sesuaikan komposisi.
4. Siapkan ukuran 1920 × 1080.
5. Siapkan aset untuk Godot.

### Tahap 3 — Implementasi UI Godot
1. Integrasikan background.
2. Masukkan logo.
3. Masukkan tombol Start Game dan About.
4. Buat interaksi tombol.
5. Buat loading screen.

### Tahap 4 — Gameplay
1. Enemy AI.
2. Combat system.
3. HP system.
4. Death animation.
5. Item drop.
6. Slime.

### Tahap 5 — Finalisasi
1. Environment polish.
2. Sound effect dan music.
3. Testing.
4. Optimasi.
5. Ekspor game.
6. Finalisasi dokumentasi HKI.

---

## 12. Catatan Penting untuk Pengembangan Selanjutnya

1. **Jangan mengubah logo ELYS yang sudah disetujui.** Gunakan desain lettering final sebagai identitas utama.
2. **Jaga konsistensi warna.** Turquoise, emerald, cyan, dan antique gold menjadi identitas visual utama.
3. **Bedakan gaya aset karakter dan environment.** Karakter menggunakan pixel art, sedangkan background menggunakan painterly fantasy.
4. **Jangan mengembalikan altar ke background terbaru.** Revisi terakhir secara eksplisit meminta penghapusan seluruh altar dan struktur serupa.
5. **Pertahankan komposisi chest kiri dan interface area kanan** untuk background terbaru yang sedang dikembangkan.
6. **Jangan mencampurkan UI dengan background.** Logo, tombol, dan loading bar harus menjadi aset terpisah agar mudah diatur di Godot.
7. **Gunakan aset yang sudah disetujui sebagai acuan.** Jangan membuat ulang desain yang sudah final tanpa permintaan.

---

## 13. Status Keseluruhan Proyek

| Bagian | Status |
|---|---|
| Identitas visual | Konsep disetujui |
| Typography logo | Desain dipilih |
| Emblem | Aset tersedia |
| Spritesheet karakter | Aset dikembangkan |
| Environment background | Dalam tahap finalisasi |
| UI button | Eksplorasi desain |
| Godot gameplay | Pengembangan |
| Manual Book HKI | Dokumentasi |

### Prioritas Terdekat

Finalisasi background dan UI home screen, kemudian integrasikan seluruh aset visual ke dalam project Godot.

---

## Kesimpulan

Proyek ELYS sudah memiliki arah identitas visual yang cukup jelas. Fokus pengembangan berikutnya bukan lagi mencari identitas baru, melainkan menyatukan aset yang sudah dibuat menjadi satu pengalaman game yang konsisten, mulai dari loading screen, home screen, karakter, environment, hingga gameplay.

> **Catatan status:** Rekap ini menggabungkan detail percakapan dan keputusan proyek yang tersedia. Status selesai berarti aset atau konsepnya sudah pernah dibuat atau dikembangkan, bukan otomatis berarti seluruhnya sudah terintegrasi dan diuji di dalam Godot.

**END OF PROJECT SUMMARY**
