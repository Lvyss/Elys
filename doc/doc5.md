# Rekap Gabungan Proyek Godot dan Aset Sprite

Dokumen ini menggabungkan dua rekap sumber menjadi satu berkas. Bagian-bagiannya tetap dipisahkan karena rekap pertama membahas aset animasi Goblin dan Hero, sedangkan rekap kedua membahas game Godot 3D dengan karakter pixel art. Catatan atau instruksi yang tertulis di dalam rekap sumber dipertahankan sebagai isi dokumentasi proyek; instruksi tersebut bukan permintaan baru untuk dilakukan sekarang.

---

# Rekap Proyek Animasi Sprite 2D Goblin dan Hero

Workspace proyek: `C:\Users\ASUS\OneDrive\Dokumen\ChatGPT\nieee`

## ✅ Yang Sudah Dikerjakan

### Animasi WALK Goblin

- Dibuat animasi berjalan untuk empat arah: `EAST`, `SOUTH`, `NORTH`, dan `WEST`.
- Setiap arah berisi **4 frame**, total **16 PNG**.
- ZIP: `GOBLIN_WALK.zip`
- Struktur arsip: `GOBLIN/WALK/{EAST,SOUTH,NORTH,WEST}/frame_01.png` hingga `frame_04.png`.
- PNG hasil potong berukuran **543 × 724 piksel**. Transparansi diperiksa pada piksel sudut.

### Animasi ATTACK Goblin

- Dibuat rangkaian enam pose per arah, mencakup ancang-ancang, mengangkat pentungan, ayunan, akhir ayunan, pemulihan, dan pose siap.
- Empat arah, masing-masing **6 frame**, total **24 PNG**.
- ZIP: `GOBLIN_ATTACK.zip`
- Struktur arsip: `GOBLIN/ATTACK/{EAST,SOUTH,NORTH,WEST}/frame_01.png` hingga `frame_06.png`.
- PNG berukuran **445 × 724 piksel** dan memiliki background transparan.

### Animasi DEATH Goblin

- Dibuat delapan pose per arah: terkena serangan, kehilangan keseimbangan, jatuh, terbaring, lalu memudar menjadi partikel atau asap.
- Empat arah, masing-masing **8 frame**, total **32 PNG**.
- ZIP: `GOBLIN_DEATH.zip`
- Struktur arsip: `GOBLIN/DEATH/{EAST,SOUTH,NORTH,WEST}/frame_01.png` hingga `frame_08.png`.
- Seluruh PNG diperiksa berukuran **642 × 724 piksel**; nilai alpha di sudut kanvas adalah 0. Isi ZIP diperiksa memiliki 32 PNG.

### Desain goblin dan pentungan

- Referensi menampilkan goblin hijau zaitun berotot, bertelinga runcing, bermata kuning, bertaring, memakai cawat cokelat, dan membawa pentungan kayu besar berbentuk paha ayam dengan lilitan kawat logam.
- Prompt animasi mempertahankan ciri tersebut dan meminta gaya pixel art, latar transparan, serta tanpa kapak.
- Aset animasi dibuat dari strip gambar sementara yang kemudian dipotong menjadi PNG individual. Strip tidak disertakan sebagai output ZIP.

## ⚠️ Catatan dan Perbedaan dari Rencana Awal

- **Permintaan Hero SOUTH dengan pedang tersarung di punggung belum terselesaikan dengan benar.** ZIP awal `south_sheathed_character.zip` dibuat dari aset workspace yang sudah ada, tetapi pedang masih terlihat di sisi kanan karakter. Hal ini sudah disampaikan dalam percakapan dan belum diperbaiki.
- Strip animasi Goblin dihasilkan terpisah per arah dan kemudian dipotong manual. Kesamaan desain antar-frame dan antar-arah belum dipastikan identik secara pixel-perfect.
- Ukuran kanvas keluaran berbeda antar-aksi: WALK **543 × 724**, ATTACK **445 × 724**, dan DEATH **642 × 724**. Ukuran konsisten dalam masing-masing animasi, tetapi belum diseragamkan antar-aksi.
- Batas potong strip ATTACK dan DEATH ditentukan manual agar pose tidak terpotong. Belum ada pemeriksaan visual menyeluruh terhadap setiap PNG setelah pemotongan.
- ZIP WALK, ATTACK, dan DEATH masing-masing hanya berisi rangkaian aksi terkait. Arsip belum digabung menjadi satu paket proyek.

## 📌 Belum Dikerjakan

### Pemeriksaan aset Goblin

- [ ] Tinjau semua PNG satu per satu untuk memastikan tidak ada pose, pentungan, atau partikel yang terpotong pada batas crop.
- [ ] Periksa konsistensi ukuran goblin, posisi kaki, skala pentungan, palet, outline, dan detail antar-frame serta antar-arah.
- [ ] Periksa transisi urutan frame secara visual, terutama pemudaran DEATH dan sambungan pose awal/akhir WALK.
- [ ] Uji animasi di game atau editor target; belum ada pengujian runtime dalam percakapan ini.

### Hero SOUTH

- [ ] Perbaiki animasi Hero SOUTH supaya pedang benar-benar berada di belakang badan dan tidak terlihat di samping pada tampak depan.
- [ ] Belum dipastikan apakah rangkaian Hero perlu diperbarui atau cukup mengganti ZIP sebelumnya.

### Integrasi dan pengemasan proyek

- [ ] Belum ada integrasi ke engine game atau konfigurasi animasi (nama state, frame rate, durasi frame, loop, anchor/pivot).
- [ ] Belum dibuat ZIP gabungan WALK, ATTACK, dan DEATH.
- [ ] Belum ditetapkan frame rate atau timing untuk tiap animasi.

## 🐛 Kendala dan Solusi

### Selesai

- **Pemotongan strip ATTACK pertama gagal** karena PowerShell menafsirkan parameter `Rectangle` secara keliru. Perintah diperbaiki dengan membuat `System.Drawing.Rectangle` secara eksplisit; frame kemudian berhasil dibuat dan ZIP berhasil dikemas.
- **Pembuatan ZIP Goblin awal menghasilkan arsip yang tidak lengkap** pada percobaan pertama karena kesalahan pemotongan yang sama. Arsip dibangun ulang setelah koreksi.
- Untuk DEATH, delapan strip empat-panel diproses menjadi delapan frame per arah. Pemeriksaan akhir memastikan terdapat 32 PNG, ukuran seragam dalam animasi tersebut, dan transparansi di sudut kanvas.

### Masih perlu perhatian

- Pemotongan manual dan generasi gambar dapat menghasilkan perubahan skala, posisi, atau bentuk antar-frame. Pemeriksaan teknis memastikan jumlah file dan transparansi, tetapi belum memastikan semua frame tampak mulus ketika dianimasikan.
- Pada pratinjau strip DEATH SOUTH terlihat beberapa aksen warna merah di sekitar partikel/asap. Belum diperiksa atau dibersihkan pada PNG akhir.

## 🚀 Langkah Berikutnya yang Disarankan

1. Buka dan tinjau frame individual WALK, ATTACK, dan DEATH, terutama pada batas antar-pose dan efek partikel.
2. Perbaiki frame yang terlihat terpotong, berubah skala, atau tidak konsisten; periksa khusus DEATH SOUTH.
3. Tetapkan timing dan frame rate, lalu uji urutan WALK loop, ATTACK, dan DEATH di engine atau editor game yang digunakan.
4. Kembali ke aset Hero SOUTH dan koreksi penempatan pedangnya jika pekerjaan Hero masih menjadi bagian proyek.
5. Setelah aset disetujui, buat paket ZIP gabungan jika diperlukan.


---

# Rekap Proyek Godot -- 3D Nano Game dengan Karakter Pixel Art

Rekap ini merangkum perkembangan proyek berdasarkan riwayat percakapan
yang tersedia hingga 31 Oktober 2026. Informasi yang belum pernah
dikonfirmasi ditandai secara eksplisit agar tidak dianggap sebagai hasil
pengerjaan.

## ✅ Yang Sudah Dikerjakan

### 1. Project dan konfigurasi Godot

-   Engine: **Godot 4.3+**.
-   Renderer: **Compatibility**.
-   Default Texture Filter: **Nearest**.
-   Proyek merupakan game 3D untuk tugas UTS Nano Game.
-   Karakter menggunakan visual pixel art 2D di dalam lingkungan 3D.
-   Pengerjaan dilakukan secara individu.

### 2. Konsep dan level maze

-   Maze dirancang menggunakan empat digit terakhir NIM: **4-8-0-8**.
-   Setiap digit menjadi bagian dari jalur maze.
-   Rancangan level mencakup dinding maze yang memiliki ketinggian,
    perbedaan warna dinding dan lantai, jalur masuk dan keluar pada
    setiap bagian digit, mob/enemy, serta area finish.

Catatan: Bentuk akhir maze dan apakah angka harus tampak jelas sebagai
bentuk maze belum dikonfirmasi.

### 3. Struktur scene dan player

Struktur scene yang pernah dibahas pada tahap awal:

``` text
Maze (Node3D)
├── Ground
├── GridMap
├── gol (Area3D)
└── Player (CharacterBody3D)
    ├── Pivot
    ├── CollisionShape3D
    ├── Mesh
    └── MobDetector
```

Pada pengembangan berikutnya, visual player menggunakan
`AnimatedSprite3D` dengan nama node `Sprite`, sehingga node path yang
digunakan dalam script adalah `$Sprite`.

Struktur lengkap Scene Tree terbaru belum dikonfirmasi. Struktur di atas
merupakan struktur yang pernah dibahas, bukan jaminan bahwa seluruh node
masih sama pada project saat ini.

### 4. Movement player

Player menggunakan:

-   Node utama: `CharacterBody3D`.
-   Node visual: `AnimatedSprite3D`.
-   Input arah melalui Input Map.
-   Gerakan disesuaikan dengan orientasi kamera.
-   Kecepatan walking dan running dibedakan.
-   Running diaktifkan menggunakan mekanisme double tap pada tombol arah
    yang sama.

Input Map yang digunakan:

``` text
left
right
up
down
kill
```

Aksi `kill` dipetakan ke tombol Enter.

Konstanta pada script terakhir yang dibahas:

``` gdscript
const SPEED := 5.0
const RUN_SPEED := 5.5
const DOUBLE_TAP_TIME := 300 # milliseconds
const KILL_SPEED_SCALE := 2.0
```

Keterangan:

-   `SPEED`: kecepatan gerak normal.
-   `RUN_SPEED`: kecepatan gerak saat berlari.
-   `DOUBLE_TAP_TIME`: batas waktu deteksi double tap dalam milidetik.
-   `KILL_SPEED_SCALE`: pengali kecepatan pemutaran animasi Kill.

### 5. Sistem animasi player

Karakter memiliki rancangan animasi empat arah:

-   East -- menghadap kanan.
-   West -- menghadap kiri.
-   North -- menghadap atas.
-   South -- menghadap bawah.

Nama animasi yang digunakan:

**Idle**

``` text
idle_east
idle_west
idle_north
idle_south
```

**Walking**

``` text
walking_east
walking_west
walking_north
walking_south
```

**Running**

``` text
running_east
running_west
running_north
running_south
```

**Kill**

``` text
kill_east
kill_west
kill_north
kill_south
```

Hal yang sudah dibahas dan dibuat dalam script:

-   Animasi dipilih berdasarkan arah gerakan.
-   Animasi idle digunakan ketika player tidak bergerak.
-   Animasi walking digunakan ketika player bergerak normal.
-   Animasi running digunakan ketika mekanisme double tap aktif.
-   Animasi Kill dipanggil menggunakan tombol Enter.
-   Movement dihentikan selama animasi Kill berlangsung.
-   Setelah animasi Kill selesai, player dikembalikan ke idle.

Node sprite pada script:

``` gdscript
@onready var sprite: AnimatedSprite3D = $Sprite
```

Signal yang digunakan:

``` gdscript
sprite.animation_finished.connect(_on_animation_finished)
```

### 6. Kecepatan animasi

Kecepatan movement dan kecepatan pemutaran animasi merupakan dua hal
berbeda.

Rekomendasi FPS yang pernah dibahas:

-   Idle: 4--6 FPS.
-   Walking: 8--10 FPS.
-   Running: 12--16 FPS.
-   Kill: 12--16 FPS.

Rekomendasi nilai awal:

-   Idle: 5 FPS.
-   Walking: 8 FPS.
-   Running: 12 FPS.
-   Kill: 14 FPS.

Nilai tersebut adalah rekomendasi, bukan konfirmasi bahwa seluruh
animasi sudah diatur menggunakan FPS tersebut.

Untuk mengubah kecepatan pemutaran animasi melalui script digunakan:

``` gdscript
sprite.speed_scale = KILL_SPEED_SCALE
```

Setelah animasi selesai, nilainya dikembalikan ke:

``` gdscript
sprite.speed_scale = 1.0
```

### 7. Shadow player

**Status: berhasil muncul.**

Awalnya player tidak menghasilkan bayangan meskipun `Cast Shadow` sudah
diaktifkan. Pengujian menggunakan `BoxMesh` menunjukkan bahwa sistem
shadow pada scene bekerja, sedangkan `AnimatedSprite3D` tidak
menghasilkan bayangan.

Pengaturan yang diperiksa:

**GeometryInstance3D / Geometry**

-   Transparency: `0.0`.
-   Cast Shadow: `On`.

**Material / Flags**

-   Billboard: `Disabled`.
-   Transparent: `On`.
-   Shaded: `On`.
-   Double Sided: `On`.
-   No Depth Test: `Off`.
-   Fixed Size: `Off`.
-   Alpha Cut: awalnya `Disabled`.

Solusi yang berhasil:

-   Mengubah `Alpha Cut` dari `Disabled` menjadi **`Discard`**.
-   `Alpha Scissor Threshold` tetap `0.5`.
-   `Cast Shadow` tetap `On`.
-   `Transparent` tetap `On`.

Setelah `Alpha Cut` diubah menjadi `Discard`, shadow player akhirnya
muncul.

## ⚠️ Catatan dan Perbedaan dari Rencana Awal

### 1. Visual player

-   Proyek menggunakan lingkungan 3D.
-   Karakter kemudian dikembangkan menggunakan `AnimatedSprite3D` dengan
    pixel art 2D.
-   Dengan demikian, visual karakter berupa sprite 2D di dalam
    lingkungan 3D.

### 2. Sistem shadow

-   Kondisi awal: `Cast Shadow` sudah `On`, tetapi bayangan player tidak
    muncul.
-   Pengujian `BoxMesh` menghasilkan bayangan.
-   Masalah ditemukan pada pengaturan alpha sprite.
-   Kondisi terbaru: shadow player sudah muncul setelah `Alpha Cut`
    diubah menjadi `Discard`.

### 3. Movement dan animasi

-   `SPEED` dan `RUN_SPEED` mengatur kecepatan gerakan karakter.
-   `sprite.speed_scale` mengatur kecepatan pemutaran animasi.
-   Animasi Kill menggunakan pengaturan kecepatan tersendiri.
-   Jangan mengubah `SPEED` untuk mempercepat FPS animasi.

### 4. Mekanisme running

-   Running menggunakan double tap pada tombol arah yang sama.
-   Batas waktu double tap adalah 300 milidetik.
-   Running berhenti ketika tombol arah yang digunakan dilepaskan.

## 📌 Belum Dikerjakan

Daftar ini berisi pekerjaan yang belum terkonfirmasi selesai. Item yang
sudah selesai tidak dimasukkan sebagai pekerjaan baru.

### A. Player dan animasi

-   [ ] Menguji seluruh animasi idle pada empat arah.
-   [ ] Menguji seluruh animasi walking pada empat arah.
-   [ ] Menguji seluruh animasi running pada empat arah.
-   [ ] Menguji seluruh animasi Kill pada empat arah.
-   [ ] Memastikan transisi antaranimasi berjalan mulus.
-   [ ] Memastikan FPS setiap animasi sudah sesuai.
-   [ ] Memastikan shadow mengikuti karakter pada seluruh arah dan
    animasi.
-   [ ] Memastikan tidak ada bagian sprite yang terpotong setelah
    menggunakan `Alpha Cut → Discard`.

### B. Movement dan kontrol

-   [ ] Menguji movement pada seluruh arah.
-   [ ] Menguji mekanisme double tap secara konsisten.
-   [ ] Menguji perbedaan kecepatan walking dan running.
-   [ ] Memastikan movement tidak aktif selama animasi Kill.
-   [ ] Memastikan player dapat bergerak kembali setelah animasi Kill
    selesai.
-   [ ] Menguji movement terhadap kamera dari berbagai posisi.

### C. Maze dan lingkungan

-   [ ] Memastikan bentuk maze 4-8-0-8 sudah selesai.
-   [ ] Memastikan setiap bagian digit memiliki jalur masuk dan keluar.
-   [ ] Memastikan tinggi dinding cukup untuk menghalangi player.
-   [ ] Memastikan collision seluruh dinding berfungsi.
-   [ ] Memastikan player tidak bisa menembus dinding.
-   [ ] Memastikan kamera dapat mengikuti player dengan baik.
-   [ ] Menyesuaikan tampilan kamera agar area permainan terlihat
    proporsional.

### D. Enemy / mob

-   [ ] Memastikan minimal tiga mob pada setiap bagian digit.
-   [ ] Memastikan seluruh mob dapat bergerak sesuai mekanisme yang
    dirancang.
-   [ ] Memastikan collision antara player dan mob berfungsi.
-   [ ] Memastikan `MobDetector` berfungsi sesuai tujuan.
-   [ ] Memastikan mekanisme Kill benar-benar berpengaruh terhadap mob.

### E. Gameplay dan penyelesaian level

-   [ ] Menguji area `gol (Area3D)`.
-   [ ] Memastikan player dapat mencapai area finish.
-   [ ] Menghubungkan kondisi finish dengan tampilan Victory.
-   [ ] Menambahkan atau memastikan efek partikel kemenangan.
-   [ ] Memastikan permainan memiliki alur mulai sampai selesai.

### F. UI dan tampilan game

-   [ ] Memastikan Home / Play Screen sudah dibuat.
-   [ ] Memastikan tombol Play dapat memulai permainan.
-   [ ] Memastikan tampilan game sesuai konsep top-down horror yang
    pernah direncanakan.
-   [ ] Memastikan fog dan pencahayaan sudah sesuai.
-   [ ] Menguji tampilan pada orientasi portrait yang direncanakan.

### G. Pengujian dan dokumentasi

-   [ ] Melakukan pengujian keseluruhan game dari awal hingga akhir.
-   [ ] Memastikan tidak ada error pada debugger.
-   [ ] Memastikan semua fitur dapat digunakan dalam satu alur
    permainan.
-   [ ] Mempersiapkan video demo berdurasi 3--5 menit sesuai ketentuan
    tugas UTS.
-   [ ] Memastikan hasil akhir dapat dijalankan dan dikumpulkan.

## 🐛 Kendala dan Solusi

### 1. Player tidak memiliki shadow

**Status: selesai.**

Masalah:

-   `Cast Shadow` sudah `On`, tetapi player tidak menghasilkan bayangan.
-   `BoxMesh` berhasil menghasilkan bayangan sehingga sistem shadow pada
    scene bekerja.

Penyebab yang ditemukan:

-   Pengaturan alpha pada material sprite.

Solusi:

-   Mengubah `Alpha Cut` menjadi `Discard`.
-   Mempertahankan `Alpha Scissor Threshold` pada `0.5`.

Hasil:

-   Shadow player berhasil muncul.

### 2. Perbedaan kecepatan movement dan animasi

**Status: sudah dijelaskan; pengujian akhir belum dikonfirmasi.**

Masalah:

-   Animasi Kill terasa lambat.
-   Ada kebingungan mengenai pengaruh `SPEED` terhadap animasi.

Solusi yang dibahas:

-   Movement menggunakan `SPEED` dan `RUN_SPEED`.
-   Kecepatan animasi menggunakan `sprite.speed_scale`.
-   Animasi Kill menggunakan `KILL_SPEED_SCALE`.

Catatan:

-   Belum ada konfirmasi bahwa kecepatan akhir animasi Kill sudah sesuai
    keinginan.

### 3. Animasi Kill tidak berhenti

**Status: pengaturan Loop belum dikonfirmasi.**

Hal yang perlu diperhatikan:

-   Animasi Kill harus menggunakan Loop OFF agar signal
    `animation_finished` dapat mengembalikan player ke idle.
-   Animasi idle, walking, dan running menggunakan Loop ON.

### 4. Kendala collision maze

**Status: pernah dinyatakan selesai.**

Masalah:

-   Collision pada GridMap / dinding maze sempat mengalami kendala.

Hasil:

-   Kendala GridMap wall collision pernah dinyatakan sudah diperbaiki.
-   Detail perubahan teknis belum tercatat lengkap.

### 5. Kamera tidak menampilkan seluruh map

**Status: belum terkonfirmasi selesai.**

Masalah:

-   Ukuran map sekitar 200 × 100.
-   Kamera tidak dapat menampilkan seluruh area sekaligus.

Catatan:

-   Kamera follower pernah dibahas.
-   Solusi akhir dan konfigurasi kamera terbaru belum dikonfirmasi.

## 🚀 Langkah Berikutnya yang Disarankan

### 1. Finalisasi player

Prioritaskan pengujian player karena animasi dan shadow baru saja
dikembangkan.

-   [ ] Tes walking, running, idle, dan Kill.
-   [ ] Pastikan transisi animasi berjalan dengan benar.
-   [ ] Pastikan shadow mengikuti sprite.
-   [ ] Sesuaikan FPS animasi jika masih terlalu lambat atau terlalu
    cepat.
-   [ ] Pastikan player tidak bergerak selama animasi Kill.

### 2. Finalisasi movement dan collision

-   [ ] Uji movement pada seluruh arah.
-   [ ] Uji double tap.
-   [ ] Uji collision dengan dinding.
-   [ ] Pastikan player tidak keluar dari batas maze.

### 3. Lanjutkan enemy dan interaksi

-   [ ] Periksa kembali seluruh mob.
-   [ ] Pastikan jumlah mob sesuai ketentuan.
-   [ ] Hubungkan interaksi Kill dengan mob.
-   [ ] Uji collision dan respons ketika player berinteraksi dengan
    enemy.

### 4. Selesaikan alur gameplay

-   [ ] Periksa jalur maze dari awal sampai akhir.
-   [ ] Pastikan area finish dapat mendeteksi player.
-   [ ] Selesaikan tampilan Victory.
-   [ ] Pastikan efek kemenangan dapat dipanggil.

### 5. Finalisasi UI dan visual

-   [ ] Selesaikan Home / Play Screen.
-   [ ] Rapikan kamera.
-   [ ] Sesuaikan fog dan pencahayaan.
-   [ ] Pastikan warna lingkungan dan karakter tetap terbaca.

### 6. Pengujian dan pengumpulan

-   [ ] Mainkan game dari awal sampai akhir.
-   [ ] Periksa error dan warning.
-   [ ] Pastikan semua fitur utama bekerja.
-   [ ] Rekam video demo 3--5 menit.
-   [ ] Siapkan file project dan kebutuhan pengumpulan.

## Informasi Teknis Penting untuk Percakapan Berikutnya

**Engine dan konfigurasi**

-   Godot 4.3+.
-   Renderer Compatibility.
-   Default Texture Filter Nearest.

**Player**

-   Node utama: `CharacterBody3D`.
-   Node sprite: `AnimatedSprite3D`.
-   Nama node sprite: `Sprite`.
-   Node path: `$Sprite`.

**Input Map**

``` text
left
right
up
down
kill
```

**Nama animasi**

``` text
idle_east
idle_west
idle_north
idle_south

walking_east
walking_west
walking_north
walking_south

running_east
running_west
running_north
running_south

kill_east
kill_west
kill_north
kill_south
```

**Variabel movement terakhir yang dibahas**

``` gdscript
const SPEED := 5.0
const RUN_SPEED := 5.5
const DOUBLE_TAP_TIME := 300
const KILL_SPEED_SCALE := 2.0
```

**Pengaturan shadow yang berhasil**

``` text
Cast Shadow: On
Transparent: On
Shaded: On
Double Sided: On
Alpha Cut: Discard
Alpha Scissor Threshold: 0.5
```

**Signal animasi**

``` gdscript
sprite.animation_finished.connect(_on_animation_finished)
```

**Hal penting untuk melanjutkan proyek**

-   Jangan mengubah `SPEED` untuk mempercepat FPS animasi.
-   Gunakan `sprite.speed_scale` atau FPS pada SpriteFrames.
-   Animasi Kill harus Loop OFF.
-   Shadow player sudah berhasil muncul dengan `Alpha Cut → Discard`.
-   Jangan menganggap semua checklist sudah selesai hanya karena pernah
    direncanakan.

**Instruksi untuk AI di percakapan baru:** Lanjutkan pengerjaan dari
kondisi terakhir, yaitu player `AnimatedSprite3D` sudah memiliki shadow
setelah pengaturan `Alpha Cut` menjadi `Discard`. Jangan mengulang
tutorial konfigurasi shadow dari awal kecuali muncul masalah baru.
Berikan panduan Godot secara bertahap sesuai node dan Inspector yang
sedang digunakan. Jika pengguna meminta perubahan script, perhatikan
script terakhir yang pernah dibahas dan jangan menghapus fitur movement,
double tap, animasi empat arah, atau Kill yang sudah ada.

