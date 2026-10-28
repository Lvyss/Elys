# ELYS: Game Design Document

**Mata kuliah:** Workshop PPLG GameProg
**Topik materi:** Polymorphism dan Abstraction (OOP)
**Engine:** Godot 4.x, ekspor Web
**Versi dokumen:** 1.2
**Pengembang dan dosen:** (isi nama)

---

## 1. Concept & Vision

### 1.1 Ringkasan

| Item          | Isi                                                                             |
| ------------- | ------------------------------------------------------------------------------- |
| Judul         | Elys                                                                            |
| Genre         | Action-adventure mini + puzzle (berburu, menukar, memecahkan teka-teki)         |
| Platform      | Web browser (desktop)                                                           |
| Gaya visual   | HD-2D: dunia 3D low-poly bertekstur pixel, sprite 2D billboard, post-processing |
| Target pemain | Mahasiswa dan pemain casual usia 15-25                                          |
| Durasi main   | 12-18 menit (3 level)                                                           |
| Kontrol       | Keyboard dan mouse                                                              |

### 1.2 Pitch

L, seorang pengembara, tersesat di Hutan Hollow yang selalu berkabut. Di depan gubuk seorang kakek pemburu ada **peti kuno yang tak pernah terbuka selama puluhan tahun**. Untuk membukanya, L harus berburu monster, mengumpulkan **tiga pecahan rune**, menyatukannya, dan menjawab teka-teki yang tertulis di rune itu. Jawaban benar menempa **Kunci Fajar**.

### 1.3 Design Pillars

1. **Atmosfer dulu.** Cahaya, kabut, dan warna jadi bintang. Mekanik sedikit tapi matang.
2. **Materi dipelajari lewat dunia game.** Polymorphism dan Abstraction hadir sebagai lore, catatan yang bisa dibaca pemain, dan teka-teki rune.
3. **Satu kit aset, tiga wajah.** Level dibedakan lewat layout, pencahayaan, dan musuh.
4. **Pemain tidak pernah bingung.** Ada tutorial interaktif dan halaman Cara Bermain yang bisa dibuka kapan saja.
5. **Scope kecil, selesai.** Fitur di luar dokumen ini tidak dibuat.

### 1.4 Referensi dan pembeda

- **Visual:** Octopath Traveler (HD-2D).
- **Struktur:** petualangan mini bergaya Zelda klasik (kunci dan peti).
- **Pembeda:** pertanyaan materi kuliah dikemas sebagai teka-teki rune berbahasa fantasi, dan catatan materi ditemukan pemain sepanjang petualangan.

### 1.5 Pemetaan materi ke pengalaman pemain

| Konsep           | Di lore                            | Dipelajari lewat    | Diuji lewat                  |
| ---------------- | ---------------------------------- | ------------------- | ---------------------------- |
| **Abstraction**  | "Cetak Biru": kewajiban tanpa rupa | Catatan Penempa I   | Teka-teki rune (Set A dan C) |
| **Polymorphism** | "Satu mantra, banyak wujud"        | Catatan Penempa II  | Teka-teki rune (Set B dan C) |
| Keduanya         | "Kontrak dan Wujud"                | Catatan Penempa III | Teka-teki rune (Set C)       |

---

## 2. Cerita dan Lore

**Latar:** Hutan Hollow dulu dijaga para **Penempa Rune**. Harta terakhir mereka, **Lentera Fajar**, disimpan di **Peti Tua** yang hanya terbuka oleh **Kunci Fajar**. Kunci itu dipecah menjadi tiga **Pecahan Rune** yang ditulisi teka-teki, supaya hanya orang yang memahami "ilmu cetak dan wujud" yang bisa menyatukannya. Sejak para penempa menghilang, kabut tak pernah naik lagi.

**Tokoh:**

- **L:** pengembara bertudung, pedang pendek, syal merah.
- **Kakek Orrin:** pemburu pensiunan penghuni gubuk. Membeli hasil buruan dan menukar bahan. Tahu soal peti, tapi tak pernah berhasil membukanya.

### 2.1 Tiga level

| Level | Judul                  | Peta                                                                     | Musuh                        | Tujuan                                                  | Pecahan | Isi pecahan     |
| ----- | ---------------------- | ------------------------------------------------------------------------ | ---------------------------- | ------------------------------------------------------- | ------- | --------------- |
| 1     | **Jalan Berkabut**     | Peta A (hutan masuk dan gubuk, peti terlihat sejak awal)                 | Slime hijau                  | Tutorial, lalu kalahkan 5 slime                         | I       | Latar teka-teki |
| 2     | **Sarang Goblin**      | Peta B (kamp goblin, lebih gelap dan berkabut tebal)                     | Goblin, slime hijau          | Kalahkan 4 goblin dan 3 slime                           | II      | Isi/perumpamaan |
| 3     | **Fajar di Gubuk Tua** | Peta A dipakai ulang (layout musuh dan lighting berbeda, altar ditambah) | Goblin, slime hijau dan biru | Kalahkan 6 musuh campuran, susun rune, jawab, buka peti | III     | Pertanyaan      |

**Dialog Orrin (ringkas):**

- Level 1 awal: tentang peti misterius dan tiga rune yang tercecer.
- Selesai level 1: "Satu pecahan telah kembali. Yang lain ada di sarang goblin."
- Level 3 awal: "Letakkan semuanya di altar. Pecahan itu akan bicara padamu."
- Ending: peti terbuka, Lentera Fajar menyala, kabut naik.

### 2.2 Catatan Penempa (materi yang dibaca pemain)

Setiap kali pemain mengambil Pecahan Rune, satu **Catatan Penempa** terbuka. Catatan bisa dibaca kapan saja dari menu **Catatan** (Menu Utama, Pause, dan layar hasil level). Tiap catatan punya dua bagian: teks fantasi dan **"Terjemahan Penyihir Kode"** yang berisi definisi materinya.

**Catatan I: Cetak Biru** (terbuka setelah Pecahan I)

> _"Penempa tak menempa 'senjata' begitu saja. Ia menggambar Cetak Biru lebih dulu: setiap senjata WAJIB bisa Menyerang. Cetak Biru tak punya mata pedang dan tak bisa digenggam. Ia hanya menetapkan APA yang wajib ada, bukan BAGAIMANA caranya."_

**Terjemahan Penyihir Kode:** Abstraksi berarti menampilkan hal yang esensial dan menyembunyikan detail. Kelas abstrak adalah cetak biru yang tidak bisa dibuat menjadi objek langsung, dan berisi method abstrak yang wajib diisi oleh kelas turunannya.

**Catatan II: Satu Mantra, Banyak Wujud** (terbuka setelah Pecahan II)

> _"Penjaga gerbang hanya mengucap satu mantra: 'SERANG!' Slime menjawabnya dengan melompat menimpa, goblin dengan mengayun gada, penyihir dengan melontarkan api. Mantranya satu, wujud tindakannya banyak."_

**Terjemahan Penyihir Kode:** Polimorfisme berarti satu pemanggilan method yang sama bisa menghasilkan perilaku berbeda tergantung jenis objeknya. Biasanya diwujudkan lewat method overriding pada kelas turunan.

**Catatan III: Kontrak dan Wujud** (terbuka setelah Pecahan III)

> _"Cetak Biru menentukan kewajiban, wujud-wujud menentukan caranya. Keduanya bukan lawan, melainkan pasangan: yang satu menetapkan apa, yang lain mengisi bagaimana."_

**Terjemahan Penyihir Kode:** Abstraksi menetapkan kontrak (apa yang harus ada), polimorfisme memungkinkan tiap kelas turunan mengisi kontrak itu dengan caranya sendiri.

Catatan ini juga menjadi bekal menjawab teka-teki, jadi pemain yang membaca punya keuntungan nyata.

---

## 3. Core Loop dan Aturan Main

### 3.1 Core loop

```
Masuk level → Kalahkan musuh → Ambil drop → Capai kuota → Ambil Pecahan Rune
→ Selesai level → Toko Orrin (jual / tukar / beli) → Level berikutnya
→ Level 3: susun rune → jawab teka-teki → Kunci Fajar → buka peti → ENDING
```

### 3.2 Kontrol

| Input                | Fungsi                               |
| -------------------- | ------------------------------------ |
| W A S D (atau panah) | Bergerak 8 arah                      |
| J atau klik kiri     | Serang                               |
| E                    | Interaksi (bicara, ambil, buka peti) |
| Q                    | Pakai Ramuan                         |
| Esc                  | Pause                                |
| Mouse                | Semua menu, toko, dan puzzle rune    |

### 3.3 Atribut game (3 atribut)

| Atribut        | Nilai awal  | Sumber           | Fungsi                                                      |
| -------------- | ----------- | ---------------- | ----------------------------------------------------------- |
| **HP (nyawa)** | 100         | Ramuan, level up | Habis = Kalah                                               |
| **Koin**       | 0           | Menjual item     | Beli ramuan dan petunjuk                                    |
| **XP**         | 0 (Level 1) | Membunuh musuh   | Akumulasi XP menjadi **level**, lalu menaikkan atribut lain |

**Aturan XP:** slime 5 XP, goblin 10 XP. Tiap 30 XP naik 1 level: **+10 Max HP dan +2 Damage**, HP terisi penuh. Maksimal level 5. Ini memenuhi syarat "akumulasi atribut menjadi atribut lain".

### 3.4 Statistik

|             | HP  | Damage | Kecepatan | Deteksi | Serang                          | Catatan                            |
| ----------- | --- | ------ | --------- | ------- | ------------------------------- | ---------------------------------- |
| L (player)  | 100 | 10     | 4.5 m/s   | -       | cooldown 0.5 s, jangkauan 1.3 m | kebal 0.6 s setelah kena           |
| Slime hijau | 20  | 5      | 1.5       | 6 m     | cooldown 1.5 s                  | melompat menimpa                   |
| Slime biru  | 30  | 8      | 1.5       | 6 m     | cooldown 1.5 s                  | palette swap, level 3              |
| Goblin      | 40  | 10     | 3.0       | 8 m     | cooldown 1.2 s                  | kedip merah 0.4 s sebelum mengayun |

### 3.5 Collectible dan in-game economy

**Collectible (3 item, sesuai syarat minimal):**

| Item              | Drop                                                                       | Harga jual |
| ----------------- | -------------------------------------------------------------------------- | ---------- |
| **Lendir Slime**  | Slime 60%                                                                  | 5 koin     |
| **Taring Goblin** | Goblin 70%                                                                 | 12 koin    |
| **Kristal Kabut** | Goblin 20%, slime biru 8%, dan **dijamin 1** dari Pedestal Rune tiap level | 40 koin    |

**Tiga cara memakai item:**

1. **Jual** item menjadi koin.
2. **Tukar item menjadi booster** di Toko Orrin:

| Booster       | Biaya           | Efek                                  |
| ------------- | --------------- | ------------------------------------- |
| Ramuan Lendir | 3 Lendir Slime  | Item pakai: pulihkan 40 HP (tombol Q) |
| Asah Taring   | 3 Taring Goblin | **+5 Damage permanen** (maks 2 kali)  |
| Berkat Kabut  | 1 Kristal Kabut | **+30 Max HP permanen** (maks 3 kali) |

3. **Beli dengan koin:**

| Barang            | Harga   | Efek                                            |
| ----------------- | ------- | ----------------------------------------------- |
| Ramuan Hijau      | 20 koin | Pulihkan 40 HP                                  |
| Gulungan Petunjuk | 30 koin | Menghilangkan 1 pilihan salah di teka-teki rune |

Pemain harus memilih: menjual untuk koin atau menukar jadi kekuatan permanen. Itu inti ekonominya.

### 3.6 Teka-teki rune

**Fase 1: Menyatukan pecahan.** Di Altar Rune (level 3), pemain membuka panel dengan tiga pecahan. Tiap pecahan punya simbol di tepinya (◐, ◑, ◒). Pemain men-drag pecahan ke tiga slot sampai simbolnya cocok. Jika urutan benar, rune bersinar dan teks teka-teki muncul utuh.

**Fase 2: Menjawab.** Teka-teki tampil dengan 4 pilihan jawaban.

- **Benar:** animasi rune menempa, **Kunci Fajar** jatuh dan diambil pemain.
- **Salah:** rune bergetar, pemain kehilangan 10 HP, pilihan itu dimatikan, boleh mencoba lagi.
- Jika HP habis karena jawaban salah, hasilnya Kalah.
- Pemain bisa memakai Gulungan Petunjuk atau membuka menu Catatan.

**Fase 3: Peti.** Dekati Peti Tua, tekan E dengan kunci, peti terbuka, ending.

**Variasi:** game memilih acak 1 dari 3 set pertanyaan (bagian 4.5) di awal sesi, jadi bermain ulang tidak selalu sama.

### 3.7 Kondisi menang dan kalah

- **Menang level:** kuota tercapai dan Pecahan Rune diambil, lalu layar hasil.
- **Menang game:** peti terbuka di level 3.
- **Kalah:** HP = 0. Layar Kalah dengan pilihan _Coba Lagi_ atau _Pilih Level_. Item, koin, dan pecahan yang sudah didapat **tetap tersimpan**. Musuh di level itu di-reset.

---

## 4. Konten dan Progression

### 4.1 Layout peta (±25 x 25 m tiap peta)

**Peta A (level 1 dan 3):**

```
        ┌────────────────────────────────┐
        │ tebing dan pohon rapat (batas) │
        │   [PETI TUA]  ┌────────┐       │
        │   [ALTAR*]    │ GUBUK  │ Orrin │  Zona A (aman)
        │               └────────┘       │
        │   Zona B (kiri)  ║  Zona C     │
        │   padang rumput  ║  (kanan)    │
        │                  ║  semak      │
        │      [spawn player]            │
        └────────────────────────────────┘
        * Altar hanya aktif di level 3
```

**Peta B (level 2):** area lebih gelap, tenda goblin, api unggun mati, tumpukan peti rusak, Pedestal Rune di ujung kamp.

### 4.2 Musuh

Slime dan goblin punya pola serangan berbeda (melompat menimpa vs mengayun gada dengan peringatan merah), sehingga pemain bisa mengamati langsung bahwa "perintah menyerang yang sama" menghasilkan wujud tindakan berbeda. Ini diangkat Orrin di dialognya dan di Catatan II.

### 4.3 NPC

**Kakek Orrin:** hanya animasi idle, dengan 3-4 baris dialog per level, dan membuka Toko lewat tombol E.

### 4.4 Konten wajib vs opsional

| Wajib                                                | Opsional (jika waktu sisa) |
| ---------------------------------------------------- | -------------------------- |
| 3 level, 2 peta                                      | Animasi bicara Orrin       |
| 3 jenis musuh (slime hijau, biru, goblin)            | Shader rumput bergoyang    |
| 3 collectible + 3 pecahan rune                       | Shader tilt-shift halus    |
| Toko (jual, tukar, beli)                             | Cuaca tambahan             |
| Teka-teki rune + peti + ending                       | Tutorial lanjutan          |
| Menu lengkap, tutorial, Cara Bermain, Catatan, About | -                          |

### 4.5 Bank pertanyaan teka-teki

Tiap set terdiri dari 3 bagian yang terpisah di 3 pecahan: **Latar** (pecahan I), **Isi** (pecahan II), **Tanya** (pecahan III).

**Set A: Abstraction**

- _Latar:_ "Di Menara Ukiran, sang Penempa menetapkan sebuah Cetak Biru Senjata: setiap senjata WAJIB memiliki kemampuan Menyerang, namun Cetak Biru itu tak pernah menjelaskan bagaimana cara menyerang."
- _Isi:_ "Pedang menebas, busur melepaskan panah, tongkat memancarkan petir. Tetapi Cetak Biru itu sendiri tak pernah bisa ditempa menjadi senjata nyata."
- _Tanya:_ "Dalam bahasa para penyihir kode, apakah nama Cetak Biru yang tak dapat diwujudkan langsung itu?"
- Pilihan: A. Objek konkret | **B. Kelas abstrak (benar)** | C. Variabel global | D. Konstruktor

**Set B: Polymorphism**

- _Latar:_ "Penjaga gerbang meneriakkan satu mantra yang sama: 'SERANG!'"
- _Isi:_ "Slime melompat menimpa. Goblin mengayunkan gada. Penyihir melontarkan bola api. Mantra tetap satu, namun wujud tindakan berbeda sesuai penerimanya."
- _Tanya:_ "Apakah nama prinsip ketika satu perintah menghasilkan perilaku berbeda pada wujud yang berbeda?"
- Pilihan: A. Enkapsulasi | B. Pewarisan saja | **C. Polimorfisme (benar)** | D. Abstraksi

**Set C: Gabungan**

- _Latar:_ "Pecahan pertama berbunyi: 'Setiap makhluk WAJIB bisa bergerak dan menyerang.' Pecahan kedua berbunyi: 'Slime dan Goblin menentukan sendiri cara mereka menyerang.'"
- _Isi:_ "Pecahan pertama hanya menetapkan kewajiban tanpa menjelaskan caranya. Pecahan kedua mengisi caranya, berbeda-beda untuk tiap makhluk."
- _Tanya:_ "Apa nama untuk pecahan pertama dan pecahan kedua secara berurutan?"
- Pilihan: A. Polimorfisme, lalu Abstraksi | B. Enkapsulasi, lalu Pewarisan | **C. Abstraksi, lalu Polimorfisme (override method) (benar)** | D. Konstruktor, lalu Destruktor

Posisi jawaban diacak tiap sesi. Soal bisa disesuaikan dengan arahan dosen, pastikan tetap sejalan dengan materi di kelas.

### 4.6 Progression

```
Splash → Menu Utama → Level Select → Level 1 (tutorial) → Hasil
→ Level Select (L2 terbuka) → Level 2 → Hasil
→ Level Select (L3 terbuka) → Level 3 → Susun rune → Jawab → Kunci → Peti → Ending
```

Level terkunci sampai level sebelumnya selesai. Toko dan Catatan bisa dibuka dari Level Select.

---

## 5. UX / UI / Audio

### 5.1 Alur layar keseluruhan

```
[Splash / Logo] → [Menu Utama] ─┬─ Mulai Petualangan → Level 1
                                ├─ Pilih Level → [Level Select] → Level 1/2/3
                                ├─ Cara Bermain
                                ├─ Catatan Penempa
                                ├─ Pengaturan (volume)
                                └─ Tentang
Level → Pause (Lanjut / Cara Bermain / Catatan / Pengaturan / Menu Utama)
Level → [Hasil: Menang] / [Kalah] → Level Select atau Coba Lagi
Level 3 → [Ending] → Menu Utama
```

### 5.2 Halaman masuk (Splash dan logo)

Urutan saat game pertama dibuka:

1. **Layar klik awal:** "Klik untuk mulai". Ini wajib di web karena audio browser baru boleh jalan setelah interaksi pertama pemain.
2. **Logo pengembang/kelompok** (fade in dan out, ±2 detik).
3. **Logo ELYS** muncul di atas latar diorama hutan berkabut, dengan kabut bergerak, kunang-kunang, dan musik tema mulai pelan. Bisa dilewati dengan klik atau tombol apa saja.
4. Transisi ke **Menu Utama**.

### 5.3 Menu Utama

Latar adalah diorama 3D sungguhan (peta A pagi hari) dengan kamera bergerak lambat, supaya langsung memamerkan grafisnya.

| Tombol                | Fungsi                                                       |
| --------------------- | ------------------------------------------------------------ |
| **Mulai Petualangan** | Mulai dari Level 1 (atau lanjut ke level terbuka berikutnya) |
| **Pilih Level**       | Ke Level Select                                              |
| **Cara Bermain**      | Halaman panduan (5.5)                                        |
| **Catatan Penempa**   | Daftar catatan materi yang sudah terbuka                     |
| **Pengaturan**        | Slider volume BGM dan SFX, tombol fullscreen                 |
| **Tentang**           | Nama dan foto pengembang + dosen, kredit aset                |

Karena ini versi web, tidak ada tombol "Keluar". Pemain menutup tab browser.

### 5.4 Tutorial interaktif (Level 1)

Tutorial berjalan di dalam Level 1 sebagai prompt bertahap di bagian atas layar dengan ikon tombol. Setiap langkah selesai otomatis ketika pemain melakukan aksinya, lalu lanjut ke langkah berikutnya. Ada tombol **Lewati Tutorial** (pojok layar) yang bisa ditekan kapan saja.

| Langkah | Prompt                                                                      | Selesai saat                              |
| ------- | --------------------------------------------------------------------------- | ----------------------------------------- |
| 1       | "Gerakkan L dengan **W A S D**"                                             | Pemain bergerak ±3 meter                  |
| 2       | "Dekati slime lalu serang dengan **J** atau **klik kiri**"                  | Slime pertama dipukul                     |
| 3       | "Kalahkan slime. Item yang jatuh akan terambil otomatis jika kamu mendekat" | Item pertama terambil                     |
| 4       | "Kalau HP menipis, tekan **Q** untuk minum ramuan"                          | Pemain menekan Q (diberi 1 ramuan gratis) |
| 5       | "Kembali ke gubuk. Tekan **E** untuk bicara dengan Orrin"                   | Dialog Orrin dibuka                       |
| 6       | "Jual atau tukar hasil buruanmu di toko"                                    | Toko dibuka dan ditutup                   |
| 7       | "Tekan **Esc** untuk Pause dan membuka Catatan"                             | Pause dibuka                              |
| 8       | "Kalahkan 5 slime untuk mendapat Pecahan Rune"                              | Kuota level tampil di HUD                 |

Slime pertama di tutorial dibuat lebih lemah (HP 10) dan tidak menyerang balik lebih dulu, supaya pemain belajar dengan aman.

### 5.5 Halaman Cara Bermain

Halaman statis (bisa dibuka dari Menu Utama dan Pause) dengan 4 tab:

- **Kontrol:** gambar keyboard, tombol, dan fungsinya.
- **Tujuan:** ringkasan misi (kumpulkan 3 pecahan, jawab teka-teki, buka peti).
- **Atribut dan Item:** penjelasan HP, Koin, XP, 3 collectible, dan booster.
- **Teka-teki Rune:** cara menyusun pecahan dan menjawab, plus tips membaca Catatan.

### 5.6 Level Select

3 node di atas peta ilustrasi hutan: terkunci (abu-abu), terbuka (menyala), selesai (centang). Di bagian bawah: tombol **Toko Orrin**, **Catatan**, dan indikator pecahan rune (0 sampai 3).

### 5.7 HUD

- Kiri atas: HP bar dan level (misalnya Lv 2).
- Kanan atas: Koin dan XP bar.
- Tengah atas: tujuan level ("Slime: 3/5").
- Kiri bawah: ikon 3 pecahan rune (abu-abu, lalu menyala jika dimiliki).
- Tengah bawah: prompt interaksi ("E: Bicara").

### 5.8 Layar akhir (End Session)

- **Hasil Level (Menang):** ringkasan XP, koin, item, dan pecahan rune yang didapat, plus tombol Toko, Catatan, dan Lanjut.
- **Kalah:** teks singkat, tombol _Coba Lagi_ dan _Pilih Level_.
- **Ending:** peti terbuka, kabut naik, kredit singkat, tombol kembali ke Menu Utama.

### 5.9 Tentang (About)

Foto dan nama setiap pengembang, foto dan nama dosen (sesuai syarat PDF), lalu daftar kredit aset (dari `CREDITS.md`).

### 5.10 Feedback

| Aksi            | Visual                          | Audio         |
| --------------- | ------------------------------- | ------------- |
| Serang          | Efek tebas, shake kecil         | SFX tebas     |
| Kena hit        | Flash putih, knockback          | SFX hit       |
| Musuh mati      | Splash/asap, drop berkilau      | SFX mati      |
| Ambil item      | Kilau, ikon terbang ke HUD      | SFX pickup    |
| Jual/tukar      | Angka koin naik                 | SFX koin      |
| Level up        | Cahaya dari karakter            | Jingle pendek |
| Catatan terbuka | Ikon gulungan muncul            | SFX gulungan  |
| Rune menyatu    | Cahaya bersinar                 | SFX magis     |
| Jawaban benar   | Kunci menempa, ledakan cahaya   | Jingle sukses |
| Jawaban salah   | Rune bergetar, tepi layar merah | SFX buzz      |
| Peti terbuka    | Cahaya, kabut naik              | Musik klimaks |

### 5.11 Audio

- **BGM:** menu (tenang, tema Elys), level 1 (hutan pagi), level 2 (tegang ringan), level 3 (hangat dan klimaks), ending (pendek).
- **SFX:** langkah, tebas, hit, slime squish, goblin grunt, pickup, koin, klik UI, gulungan, rune, peti, level up.
- Format **OGG** (kecil untuk web). Lisensi free atau buatan sendiri.

### 5.12 Aksesibilitas dasar

Slider volume terpisah untuk BGM dan SFX, font pixel minimal 16 px dengan kontras tinggi, kontrol alternatif panah selain WASD, tidak ada kilatan cepat berlebihan, teks teka-teki bisa dibaca ulang kapan saja.

---

## 6. Technical Design (Godot)

### 6.1 Versi dan target

- **Godot 4.x stable**, disarankan 4.3 atau lebih baru. Cek dokumentasi versimu soal kebutuhan ekspor web.
- **Renderer: Compatibility (WebGL 2).** Untuk web ini satu-satunya pilihan.
- Resolusi dasar 1280x720, stretch mode `canvas_items`, aspect `keep`.
- Uji ekspor web sedini mungkin, jangan menunggu akhir.

### 6.2 Struktur project

```
res://
  autoload/     game_state.gd, level_manager.gd, quest_manager.gd,
                audio_manager.gd, tutorial_manager.gd
  scenes/
    menus/      splash, main_menu, level_select, how_to_play, codex,
                settings, about, end_win, end_lose, ending, shop, pause
    levels/     level_1.tscn, level_2.tscn, level_3.tscn
    maps/       map_a.tscn, map_b.tscn
    actors/     player.tscn, slime.tscn, goblin.tscn, keeper.tscn
    objects/    pickup.tscn, rune_pedestal.tscn, altar.tscn, chest.tscn
    ui/         hud.tscn, rune_puzzle.tscn, dialog.tscn, tutorial_prompt.tscn
  data/         items/*.tres, questions/*.tres, enemies/*.tres, codex/*.tres
  assets/       sprites, models, textures, audio, fonts, vfx
```

### 6.3 Teknik visual HD-2D untuk web (Compatibility)

| Efek yang diinginkan        | Teknik aman untuk web                                                                                                         |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Kabut                       | Fog kedalaman/ketinggian di Environment + plane kabut transparan bertekstur noise yang bergerak pelan                         |
| Sinar matahari tembus pohon | 3-5 plane miring bertekstur gradient, material additive                                                                       |
| Depth of field / tilt-shift | Shader fullscreen (ColorRect di CanvasLayer, `hint_screen_texture`) yang mem-blur atas dan bawah layar. Uji di versi Godot-mu |
| Bloom                       | Glow di Environment (cek tersedia di versimu) + sprite additive di sumber cahaya                                              |
| Ambient occlusion           | Bayangan blob di bawah objek dan vertex color gelap di sudut tekstur                                                          |
| Bayangan                    | `DirectionalLight3D` dengan shadow, jarak diperkecil                                                                          |
| Cahaya lokal                | Batasi `OmniLight3D` (jumlah cahaya per objek terbatas di Compatibility), sisanya pakai sprite glow                           |
| Partikel                    | `GPUParticles3D` ringan (kunang-kunang, daun, debu), total ±100 partikel                                                      |
| Rumput                      | `MultiMesh` (satu draw call), maks ±500 instance                                                                              |

**Aturan Sprite3D** (semua karakter dan dekorasi): `billboard = Y-Billboard`, `texture_filter = Nearest`, `alpha_cut = Discard`, `shaded = true`, `pixel_size = 0.02`. Kamera miring ±35° dengan `fov` kecil (±30). Skala Y sprite dikali ±1.22 untuk mengompensasi kemiringan kamera.

**Performa web:** tekstur maksimal 512 px (kecuali latar), audio OGG, hindari lightmap resolusi tinggi, uji di Chrome dan Firefox.

### 6.4 Autoload (singleton)

| Autoload          | Tugas                                                                                       |
| ----------------- | ------------------------------------------------------------------------------------------- |
| `GameState`       | HP, koin, XP, level, inventory, booster. Memancarkan sinyal ke HUD                          |
| `LevelManager`    | Pindah scene, status level (terkunci/terbuka/selesai), kuota musuh                          |
| `QuestManager`    | Pecahan rune (3 bool), set pertanyaan terpilih, status kunci dan peti, catatan yang terbuka |
| `AudioManager`    | BGM, SFX, volume                                                                            |
| `TutorialManager` | Urutan langkah tutorial, status selesai/lewati                                              |

### 6.5 Pola komunikasi

- **Signal** untuk UI (`hp_changed`, `coins_changed`, `quota_updated`, `rune_collected`, `tutorial_step_done`). UI tidak polling di `_process`.
- **Group** `"enemy"` dan `"player"` untuk pencarian target.
- **Direct call** hanya dari parent ke child.
- Hanya `GameState` yang boleh mengubah atribut. Script lain memanggil fungsinya.

### 6.6 Data

| Data            | Format                                                                                  |
| --------------- | --------------------------------------------------------------------------------------- |
| Item            | `ItemData` Resource (`.tres`)                                                           |
| Pertanyaan      | `QuestionData` Resource: `parts[3]`, `options[4]`, `correct_index`, `hint_remove_index` |
| Statistik musuh | `EnemyData` Resource                                                                    |
| Catatan         | `CodexEntry` Resource: judul, teks fantasi, terjemahan, syarat terbuka                  |
| Progress        | Disimpan di memori selama sesi. Save ke `user://` opsional                              |

### 6.7 Input map, collision, aturan kode

**Input map:** `left, right, up, down, attack, interact, use_potion, pause`.

**Collision layer:**

| Layer | Nama         |
| ----- | ------------ |
| 1     | World        |
| 2     | Player       |
| 3     | Enemy        |
| 4     | PlayerHitbox |
| 5     | EnemyHitbox  |
| 6     | Pickup       |
| 7     | Interactable |

**Aturan kode:**

- File dan variabel `snake_case`, kelas `PascalCase`, konstanta `UPPER_CASE`.
- Satu script satu tanggung jawab, usahakan maksimal ±200 baris.
- Hindari angka ajaib, pindahkan ke `const` atau Resource.
- Tidak ada `print` debug yang tersisa di build final.

### 6.8 Export Web

Preset Web, renderer Compatibility, kompresi aktif, ekspor ke `index.html`. Uji lewat server lokal dan webhost lab. Pastikan fullscreen berfungsi dan audio baru mulai setelah klik pertama (layar klik awal di 5.2 mengurus ini).

---

## 7. Production Plan

### 7.1 Milestone (urutan, tanpa tanggal)

| Milestone             | Kondisi tercapai                                                          |
| --------------------- | ------------------------------------------------------------------------- |
| **M1 Prototype**      | Peta A tampil dengan lighting dasar, L bisa berjalan, ekspor web berhasil |
| **M2 Vertical slice** | Level 1 bisa dimainkan: slime, drop, tutorial, pecahan I                  |
| **M3 Alpha**          | Semua menu, toko, level 2, teka-teki rune berfungsi                       |
| **M4 Beta**           | Level 3, peti, ending, audio lengkap, semua catatan                       |
| **M5 Release**        | Bug fix, balancing, build final, semua luaran wajib                       |

### 7.2 Urutan pengerjaan

1. Setup project (Compatibility), GitHub, Trello, input map, kamera, ekspor web percobaan.
2. Peta A: terrain, gubuk, pohon, batu, dekorasi, lighting, fog, partikel.
3. L: gerak, serang, HP, animasi.
4. Slime dan goblin: AI, damage, drop, pickup, spawner.
5. `GameState`, HUD, XP dan level.
6. Orrin, dialog, toko.
7. Tutorial dan Level 1 lengkap.
8. Peta B dan Level 2.
9. Pedestal rune, `QuestManager`, Catatan, UI puzzle rune.
10. Level 3, altar, peti, ending.
11. Splash, Menu Utama, Level Select, Cara Bermain, Pengaturan, About, layar menang/kalah.
12. Audio dan efek.
13. Testing, balancing, tuning visual akhir.
14. Build final dan semua luaran wajib.

### 7.3 Urutan pemotongan scope (jika waktu mepet)

1. Shader tilt-shift dan rumput bergoyang
2. Slime biru dan Berkat Kabut
3. Variasi pertanyaan (pakai 1 set saja)
4. Animasi bicara Orrin
5. Variasi layout Level 3 (pakai peta A apa adanya)

**Tidak boleh dipotong:** 3 level, 3 atribut, 3 collectible, ekonomi, audio, struktur menu sesuai PDF, tutorial, About, dan teka-teki rune.

### 7.4 Pipeline aset

| Aset                 | Sumber                                  | Format                  |
| -------------------- | --------------------------------------- | ----------------------- |
| Sprite karakter      | Pack free/CC0 atau buat sendiri         | PNG sprite sheet 48x48  |
| Model 3D dan tekstur | Pack low-poly + retexture               | glb/obj + PNG 64-128 px |
| Audio                | Freesound, Pixabay, Kenney, OpenGameArt | OGG                     |
| UI, logo, font       | Buat sendiri / font free                | PNG, TTF                |
| Foto About           | Pengembang dan dosen                    | JPG/PNG ≤ 512 px        |

Semua aset dicatat di `CREDITS.md` dengan format: _nama, pembuat, lisensi, link, tanggal download_. Aset AI-generated diperbolehkan oleh PDF, tapi tetap dicatat. PDF juga menyarankan memakai template, jadi template gerak 3D sederhana boleh dipakai selama sumbernya dicantumkan.

### 7.5 Manajemen proyek

- **Trello:** kolom _Backlog, To Do, Doing, Testing, Done_. Invite semua anggota, dosen, dan asisten, lalu hubungkan ke GitHub.
- **GitHub (private):** branch `main` (stabil) dan `dev`, commit kecil dan rutin, folder `docs/` berisi GDD, instrumen uji, dan hasil uji.
- **Laporan progres:** demo ke dosen/asisten sesuai jadwal kelas.
- **Backup:** salin repo ke cloud secara berkala.

### 7.6 Risiko

| Risiko                              | Antisipasi                                               |
| ----------------------------------- | -------------------------------------------------------- |
| Efek web tidak seindah desktop      | Uji ekspor web sejak awal, pakai teknik di 6.3           |
| Aset sprite tidak cocok gaya        | Pilih satu creator untuk hero, goblin, slime             |
| Build web terlalu besar atau lambat | Kompres tekstur, OGG, batasi MultiMesh                   |
| Scope bengkak                       | Ikuti 7.3, tidak ada fitur baru setelah M3               |
| Puzzle rune rumit                   | Mulai dari versi klik-pilih urutan, drag-drop belakangan |
| Tenggat HKI dan dokumen mepet       | Mulai draf HKI jauh sebelum game selesai                 |

---

## 8. Testing dan Release

### 8.1 Functional Test (developer)

| ID  | Uji                                     | Hasil yang diharapkan                                           |
| --- | --------------------------------------- | --------------------------------------------------------------- |
| F01 | Splash: klik awal, logo, lanjut ke menu | Audio mulai setelah klik, bisa di-skip                          |
| F02 | Semua tombol Menu Utama                 | Masing-masing membuka layar yang benar                          |
| F03 | Cara Bermain, 4 tab                     | Semua tab tampil dan terbaca                                    |
| F04 | Tutorial langkah 1-8                    | Tiap langkah maju otomatis, Lewati Tutorial berfungsi           |
| F05 | Gerak 8 arah dan flip sprite            | Sprite menghadap sesuai arah                                    |
| F06 | Serang slime                            | HP slime turun, slime mati, drop muncul                         |
| F07 | Serang goblin                           | Kedip merah, damage, mati                                       |
| F08 | Musuh mengenai L                        | HP turun, kebal 0.6 s                                           |
| F09 | Pickup item                             | Inventory dan HUD bertambah                                     |
| F10 | Jual item                               | Koin bertambah sesuai harga                                     |
| F11 | Tukar item jadi booster                 | Efek permanen berlaku, batas maksimum terjaga                   |
| F12 | Beli ramuan dan petunjuk                | Koin berkurang, efek berjalan                                   |
| F13 | XP dan level up                         | Max HP dan damage naik, HP penuh                                |
| F14 | Kuota musuh tercapai                    | Pedestal rune aktif                                             |
| F15 | Ambil pecahan rune                      | HUD menyala, Catatan terbuka, tersimpan antar level             |
| F16 | Menu Catatan                            | Hanya catatan yang terbuka yang bisa dibaca                     |
| F17 | Susun rune salah/benar                  | Salah ditolak, benar menampilkan teka-teki                      |
| F18 | Jawab salah/benar                       | Salah: -10 HP dan pilihan mati. Benar: kunci jatuh              |
| F19 | Gulungan Petunjuk                       | Satu pilihan salah dihilangkan                                  |
| F20 | Buka peti tanpa/dengan kunci            | Tanpa kunci ditolak, dengan kunci ending berjalan               |
| F21 | HP = 0                                  | Layar Kalah, Coba Lagi dan Pilih Level berfungsi, progress aman |
| F22 | Level Select                            | Level terkunci/terbuka sesuai progres                           |
| F23 | Pause                                   | Lanjut, Cara Bermain, Catatan, Pengaturan, Menu Utama berfungsi |
| F24 | Slider volume                           | BGM dan SFX berubah terpisah                                    |
| F25 | About                                   | Foto dan nama pengembang dan dosen tampil                       |
| F26 | Build web di Chrome dan Firefox         | Berjalan tanpa error, performa stabil                           |

### 8.2 Alpha Test (pemain)

- **Penguji:** 5-10 orang yang belum pernah melihat game (teman kelas, kelompok lain).
- **Cara:** pemain memainkan dari Splash sampai Ending tanpa dibantu. Developer hanya mengamati dan mencatat.
- **Instrumen (formulir singkat):**
  - Apakah kontrol dan tujuan jelas setelah tutorial? (skala 1-5)
  - Apakah teka-teki rune bisa dimengerti? (1-5)
  - Tingkat kesulitan (terlalu mudah, pas, terlalu sulit)
  - Kejelasan materi Polymorphism dan Abstraction setelah membaca Catatan
  - Tampilan visual dan suasana (1-5)
  - Bug atau hal membingungkan (isian bebas)
- **Metrik:** waktu menyelesaikan tiap level, jumlah kematian, jumlah jawaban salah, di langkah mana pemain macet.
- **Hasil** dirangkum dan dimasukkan ke folder `docs/` di GitHub.

### 8.3 Bug tracking dan balancing

- Bug dicatat di Trello (kolom Testing) atau GitHub Issues dengan prioritas: _Crash/blocker, Mayor, Minor_.
- **Balancing pass:** sesuaikan HP/damage musuh, drop rate, dan harga jika alpha test menunjukkan pemain terlalu cepat kaya atau terlalu sering kalah. Target: pemain rata-rata menyelesaikan satu level dalam 3-6 menit dan jarang mati lebih dari 2 kali per level.

### 8.4 Checklist rilis dan luaran wajib

- [ ] Build web sudah dideploy ke webhost lab dan diuji
- [ ] Full project di GitHub, termasuk aset final
- [ ] GDD final
- [ ] Instrumen Uji dan Hasil Uji (Functional dan Alpha) di repo
- [ ] Poster digital A4
- [ ] Video trailer ±5 menit
- [ ] HKI (draft atau terbit sesuai aturan dosen)
- [ ] `CREDITS.md` lengkap, dan kredit tampil di About

**Pasca-rilis:** tidak ada rencana patch. Jika ada perbaikan setelah penilaian, dicatat sebagai _known issues_ di repo.

---

## Lampiran: Matriks kepatuhan terhadap spesifikasi PDF

| #   | Syarat PDF                                 | Pemenuhan di Elys                                         |
| --- | ------------------------------------------ | --------------------------------------------------------- |
| 1   | Genre bebas (bukan novel/endless runner)   | Action-adventure puzzle                                   |
| 2   | 2D atau 3D                                 | 2.5D (HD-2D)                                              |
| 3   | Output Web                                 | Godot Web export, Compatibility                           |
| 4   | Keyboard/mouse/touch                       | Keyboard dan mouse                                        |
| 5   | Minimal 3 atribut                          | HP, Koin, XP (plus level turunan)                         |
| 6   | Minimal 3 collectible yang bisa dikonversi | Lendir Slime, Taring Goblin, Kristal Kabut                |
| 7   | In-game economy                            | Jual, tukar jadi booster, beli, XP menjadi level          |
| 8   | Audio dan musik                            | BGM per level, SFX lengkap (lisensi free)                 |
| 9   | Aset berlisensi free/buatan sendiri/AI     | Dicatat di `CREDITS.md`                                   |
| 10  | Minimal 3 level, cerita berkaitan materi   | Level 1-3 menyusun teka-teki Polymorphism dan Abstraction |
| 11a | Start Screen/Menu                          | Splash dan Menu Utama                                     |
| 11b | Level Select                               | Ada (bagian 5.6)                                          |
| 11c | Game Session                               | Level 1-3                                                 |
| 11d | End Session (menang/kalah)                 | Hasil, Kalah, Ending                                      |
| 11e | About (nama dan foto pengembang + dosen)   | Ada (bagian 5.9)                                          |
| 12  | Tidak dari nol, boleh template             | Pakai pack aset dan template gerak                        |
