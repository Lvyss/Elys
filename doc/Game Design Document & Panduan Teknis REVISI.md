ELYS: Game Design Document

Mata kuliah: Workshop PPLG GameProg
Topik materi: Polymorphism dan Abstraction (OOP)
Engine: Godot 4.7.2, renderer Compatibility, ekspor Web
Versi dokumen: 2.0 (menggantikan 1.2)
Pengembang dan dosen: [isi nama dan NIM]

1. Concept & Vision
   1.1 Ringkasan
   Item Isi
   Judul Elys
   Genre Action-adventure mini + puzzle (bertarung, menukar item, memecahkan teka-teki)
   Platform Web browser (desktop)
   Gaya visual HD-2D: dunia 3D low-poly bertekstur, sprite 2D billboard, post-processing
   Target pemain Mahasiswa dan pemain casual usia 15-25
   Durasi main 10-15 menit
   Kontrol Keyboard dan mouse
   Peta 1 peta (Hutan Hollow, 18 x 18 m) dengan 3 level kesulitan berbentuk zona
   Musuh 1 jenis makhluk (goblin) dengan 3 varian
   1.2 Pitch

L, seorang pengembara, tersesat di Hutan Hollow yang selalu berkabut. Di depan gubuk Kakek Orrin ada peti kuno yang tak pernah terbuka selama puluhan tahun. Untuk membukanya, L harus mengalahkan para goblin penjaga, mengumpulkan tiga pecahan rune, menyatukannya di altar, dan menjawab teka-teki yang tertulis di rune itu. Jawaban benar menempa Kunci Fajar.

1.3 Design Pillars
Atmosfer dulu. Cahaya, kabut, dan warna jadi bintang. Mekanik sedikit tapi matang.
Materi dipelajari lewat dunia game. Polymorphism dan Abstraction hadir sebagai perilaku goblin, catatan yang bisa dibaca pemain, dan teka-teki rune.
Satu peta, tiga zona. Peta dibuat padat dan matang. Level dibedakan lewat zona, jenis goblin, dan pencahayaan.
Pemain bebas memilih. Semua goblin sudah ada sejak awal, sehingga salah memilih lawan adalah bagian dari permainan.
Pemain tidak pernah bingung. Ada tutorial interaktif dan halaman Cara Bermain yang bisa dibuka kapan saja.
Scope kecil, selesai. Fitur di luar dokumen ini tidak dibuat.
1.4 Referensi dan pembeda
Visual: Octopath Traveler (HD-2D).
Struktur: petualangan mini bergaya Zelda klasik (kunci dan peti).
Pembeda: pertanyaan materi kuliah dikemas sebagai teka-teki rune berbahasa fantasi. Tiga goblin dengan satu kewajiban yang sama (menyerang) tetapi cara berbeda menjadi contoh hidup polymorphism.
1.5 Pemetaan materi ke pengalaman pemain
Konsep Di lore dan gameplay Dipelajari lewat Diuji lewat
Abstraction “Cetak Biru”: setiap goblin WAJIB bisa menyerang, tanpa menjelaskan caranya Catatan Penempa I Teka-teki rune (Set A dan C)
Polymorphism “Satu mantra, banyak wujud”: ayunan tunggal, ayunan ganda, hantaman area Catatan Penempa II Teka-teki rune (Set B dan C)
Keduanya “Kontrak dan Wujud” Catatan Penempa III Teka-teki rune (Set C) 2. Cerita dan Lore

Latar: Hutan Hollow dulu dijaga para Penempa Rune. Harta terakhir mereka, Lentera Fajar, disimpan di Peti Tua yang hanya terbuka oleh Kunci Fajar. Kunci itu dipecah menjadi tiga Pecahan Rune yang ditulisi teka-teki, supaya hanya orang yang memahami “ilmu cetak dan wujud” yang bisa menyatukannya. Sejak para penempa menghilang, para goblin menguasai hutan dan kabut tak pernah naik lagi.

Tokoh:

L: pengembara bertudung, pedang pendek, syal merah.
Kakek Orrin: pemburu pensiunan yang tinggal di dalam gubuk. Membeli hasil buruan dan menukar bahan. Tahu soal peti, tapi tak pernah berhasil membukanya.
Goblin Prajurit, Elit, dan Raja: tiga tingkat kawanan penjaga pecahan rune.
2.1 Tiga level dalam satu peta

Seluruh permainan berlangsung di Peta A (Hutan Hollow). Tiga level berupa zona kesulitan. Pemain bebas mengerjakan urutannya.

Level Judul Zona di peta Goblin Tujuan Pecahan Isi pecahan
1 Jalan Berkabut Pojok barat daya dan tenggara, dekat titik awal Prajurit x5 Kalahkan semua Prajurit awal I Latar teka-teki
2 Sarang Goblin Sisi tengah timur dan tengah barat Elit x3 Kalahkan ketiga Elit II Isi/perumpamaan
3 Fajar di Gubuk Tua Tengah utara, menjaga jalan keluar Raja x1 Kalahkan Raja III Pertanyaan

Setelah tiga pecahan terkumpul, pemain menyusun rune di altar, menjawab teka-teki, dan membuka peti.

Dialog Orrin (ringkas):

Awal: tentang peti misterius dan tiga rune yang dijaga goblin. Peringatan: “Yang besar di utara itu jangan didekati dulu.”
Setelah Pecahan I: “Satu pecahan telah kembali. Yang lain dijaga goblin yang lebih kuat.”
Setelah Pecahan III: “Letakkan semuanya di altar. Pecahan itu akan bicara padamu.”
Ending: peti terbuka, Lentera Fajar menyala, kabut naik.
2.2 Catatan Penempa (materi yang dibaca pemain)

Setiap kali pemain mengambil Pecahan Rune, satu Catatan Penempa terbuka. Catatan bisa dibaca kapan saja dari menu Catatan (Menu Utama dan Pause). Tiap catatan punya dua bagian: teks fantasi dan “Terjemahan Penyihir Kode” yang berisi definisi materinya.

Catatan I: Cetak Biru (setelah Pecahan I)

“Penempa tak menempa ‘senjata’ begitu saja. Ia menggambar Cetak Biru lebih dulu: setiap senjata WAJIB bisa Menyerang. Cetak Biru tak punya mata pedang dan tak bisa digenggam. Ia hanya menetapkan APA yang wajib ada, bukan BAGAIMANA caranya.”

Terjemahan Penyihir Kode: Abstraksi berarti menampilkan hal yang esensial dan menyembunyikan detail. Kelas abstrak adalah cetak biru yang tidak bisa dibuat menjadi objek langsung, dan berisi method abstrak yang wajib diisi oleh kelas turunannya.

Catatan II: Satu Mantra, Banyak Wujud (setelah Pecahan II)

“Penjaga gerbang hanya mengucap satu mantra: ‘SERANG!’ Prajurit menjawabnya dengan satu ayunan gada, Elit dengan dua ayunan beruntun, Raja dengan hantaman yang menggetarkan tanah. Mantranya satu, wujud tindakannya banyak.”

Terjemahan Penyihir Kode: Polimorfisme berarti satu pemanggilan method yang sama bisa menghasilkan perilaku berbeda tergantung jenis objeknya. Biasanya diwujudkan lewat method overriding pada kelas turunan.

Catatan III: Kontrak dan Wujud (setelah Pecahan III)

“Cetak Biru menentukan kewajiban, wujud-wujud menentukan caranya. Keduanya bukan lawan, melainkan pasangan: yang satu menetapkan apa, yang lain mengisi bagaimana.”

Terjemahan Penyihir Kode: Abstraksi menetapkan kontrak (apa yang harus ada), polimorfisme memungkinkan tiap kelas turunan mengisi kontrak itu dengan caranya sendiri.

Catatan ini juga menjadi bekal menjawab teka-teki, jadi pemain yang membaca punya keuntungan nyata.

3. Core Loop dan Aturan Main
   3.1 Core loop
   Mulai di titik awal → Pilih zona dan goblin yang dilawan → Kalahkan goblin
   → Ambil drop → Zona bersih → Ambil Pecahan Rune di Pedestal
   → Masuk gubuk: Toko Orrin (jual / tukar / beli) → Pilih zona berikutnya
   → Tiga pecahan terkumpul: altar → susun rune → jawab teka-teki → Kunci Fajar → buka peti → ENDING
   3.2 Kontrol
   Input Fungsi
   W A S D (atau panah) Bergerak, arah mengikuti kamera
   Mouse Memutar kamera mengelilingi L
   Scroll Zoom kamera (jarak 4 sampai 16)
   Spasi Melompat
   J atau klik kiri Serang
   E Interaksi (pintu gubuk, bicara dengan Orrin, ambil pecahan, altar, peti)
   Q Pakai Ramuan
   Esc Melepas kursor dan membuka Pause
   F11 Fullscreen
   Mouse (kursor bebas) Semua menu, toko, dan puzzle rune
   3.3 Atribut game (3 atribut)
   Atribut Nilai awal Sumber Fungsi
   HP (nyawa) 100 Ramuan, level up Habis = Kalah
   Koin 0 Menjual item Beli ramuan dan petunjuk
   XP 0 (Level 1) Mengalahkan goblin Akumulasi XP menjadi level, lalu menaikkan atribut lain

Aturan XP: Prajurit 10 XP, Elit 25 XP, Raja 60 XP. Tiap 30 XP naik 1 level: +10 Max HP dan +2 Damage, HP terisi penuh. Maksimal level 5. Ini memenuhi syarat “akumulasi atribut menjadi atribut lain”.

3.4 Statistik
HP Damage Kecepatan Deteksi Cooldown serang Peringatan Pola serangan
L (player) 100 10 4.5 m/s - 0.5 s, jangkauan 1.3 m - Kebal 0.6 s setelah kena
Goblin Prajurit (Lv.1) 40 10 3.0 8 m 1.2 s Kedip merah 0.4 s Satu ayunan gada
Goblin Elit (Lv.2) 70 15 per pukulan 3.5 9 m 2.0 s Kedip merah 0.3 s Dua ayunan beruntun
Goblin Raja (Lv.3) 120 25 2.5 10 m 2.5 s Kedip merah 0.8 s Hantaman ke tanah, radius 2.5 m
3.5 Collectible dan in-game economy

Collectible (3 item, sesuai syarat minimal):

Item Drop Harga jual
Taring Goblin Prajurit 70% 12 koin
Lempeng Besi Elit 80% 25 koin
Kristal Kabut Raja 100% dan dijamin 1 dari tiap Pedestal Rune 40 koin

Tiga cara memakai item (di Toko Orrin, di dalam gubuk):

Jual item menjadi koin.
Tukar item menjadi booster:
Booster Biaya Efek
Ramuan Taring 3 Taring Goblin Item pakai: pulihkan 40 HP (tombol Q)
Asah Besi 2 Lempeng Besi +5 Damage permanen (maks 2 kali)
Berkat Kabut 1 Kristal Kabut +30 Max HP permanen (maks 3 kali)
Beli dengan koin:
Barang Harga Efek
Ramuan Hijau 20 koin Pulihkan 40 HP
Gulungan Petunjuk 30 koin Menghilangkan 1 pilihan salah di teka-teki rune

Pemain harus memilih: menjual untuk koin atau menukar jadi kekuatan permanen. Itu inti ekonominya.

3.6 Teka-teki rune

Fase 1: Menyatukan pecahan. Di Altar Rune, pemain membuka panel dengan tiga pecahan. Tiap pecahan punya simbol di tepinya (◐, ◑, ◒). Pemain menempatkan pecahan ke tiga slot sampai simbolnya cocok. Jika urutan benar, rune bersinar dan teks teka-teki muncul utuh. Urutan salah ditolak tanpa hukuman.

Fase 2: Menjawab. Teka-teki tampil dengan 4 pilihan jawaban.

Benar: animasi rune menempa, Kunci Fajar jatuh dan diambil pemain.
Salah: rune bergetar, pemain kehilangan 10 HP, pilihan itu dimatikan, boleh mencoba lagi.
Jika HP habis karena jawaban salah, hasilnya Kalah.
Pemain bisa memakai Gulungan Petunjuk atau membuka menu Catatan.

Fase 3: Peti. Dekati Peti Tua, tekan E dengan kunci, peti terbuka, ending.

Variasi: game memilih acak 1 dari 3 set pertanyaan (bagian 4.5) di awal sesi.

3.7 Kondisi menang dan kalah
Menang zona (level): semua goblin awal di zona itu kalah, lalu Pecahan Rune diambil dari Pedestal.
Menang game: peti terbuka dengan Kunci Fajar.
Kalah: HP = 0. Layar Kalah dengan tombol Coba Lagi. Pemain bangkit di titik awal. Item, koin, XP, dan pecahan yang sudah didapat tetap tersimpan. Goblin yang belum mati kembali ke posisi awal dengan HP penuh. 4. Konten dan Progression
4.1 Layout peta (18 x 18 m)

Peta tunggal Hutan Hollow membentang X -9 sampai 9 dan Z -9 sampai 9.

UTARA
┌─────────────────────────────────────────┐
│ [Peti Tua] [RAJA Lv.3] [Gubuk Orrin] │
│ ║ │
│ [Altar Rune] [ELIT Lv.2]══[ELIT Lv.2] │
│ (3 batu) ║ │
│ [PRAJURIT] ║ [PRAJURIT] │
│ Lv.1 ★ Spawn Lv.1 │
└─────────────────────────────────────────┘
SELATAN
Zona aman: sekitar Gubuk Orrin (timur laut), Peti Tua (barat laut), dan jalur dekat titik awal.
Landmark: Gubuk Orrin (pintu menghadap selatan), Peti Tua di alas batu, Altar Rune dari tiga batu berukir, tunggul pohon, tebing berlapis.
Pembatas area bermain. Area di luar peta sengaja digelapkan agar pemain paham bahwa hanya area itu tempat bermain: kabut gelap yang menebal ke tepi, vignette, tebing dan pohon rapat di batas, serta dinding tak terlihat setinggi 4 m di empat sisi.
Interior gubuk: satu ruangan kecil terpisah (perapian, meja, Kakek Orrin) yang dimasuki lewat pintu gubuk. Ruangan ini area interaksi, bukan peta tambahan, dan tanpa pertempuran.
4.2 Musuh

Hanya ada satu jenis makhluk, goblin, dalam tiga varian. Semuanya diturunkan dari satu kelas abstrak Enemy yang mewajibkan method attack():

Enemy (abstrak)
│ properti: hp, damage, speed, detect_range, attack_cooldown
│ method wajib: attack() ← abstrak
│
├── GoblinPrajurit.attack() → satu ayunan gada
├── GoblinElit.attack() → dua ayunan beruntun
└── GoblinRaja.attack() → hantaman ke tanah (area)
Pembeda visual: Prajurit berkulit hijau zaitun, Elit lebih gelap dan berotot (palette swap), Raja berskala lebih besar. Tiap goblin memiliki label jenis dan level di atas kepalanya (contoh: “Goblin Elit Lv.2”).
Perilaku: berpatroli acak di sekitar titik awalnya, mengejar saat pemain masuk jarak deteksi, berhenti di jangkauan serang, berkedip merah, lalu menyerang. Jika pemain menjauh melewati jarak deteksi, goblin kembali ke titik awalnya.
Semua musuh ada sejak awal. Pemain boleh menyerbu Raja lebih dulu dan kemungkinan besar kalah. Orrin memberi peringatan di dialog, tetapi pilihan tetap di tangan pemain.
Respawn: Prajurit muncul kembali tiap ±45 detik (maksimal 5 aktif) agar pemain bisa berburu item. Elit dan Raja hanya muncul sekali.
4.3 NPC

Kakek Orrin: berada di dalam gubuk, hanya animasi idle, dengan 3-4 baris dialog yang berubah sesuai jumlah pecahan, dan membuka Toko lewat tombol E.

4.4 Konten wajib vs opsional
Wajib Opsional (jika waktu sisa)
1 peta, 3 zona level Animasi bicara Orrin
3 varian goblin Shader rumput bergoyang
3 collectible + 3 pecahan rune Shader tilt-shift halus
Toko di dalam gubuk (jual, tukar, beli) Cuaca tambahan
Teka-teki rune + peti + ending Tutorial lanjutan
Menu lengkap, tutorial, Cara Bermain, Catatan, About -
4.5 Bank pertanyaan teka-teki

Tiap set terdiri dari 3 bagian yang terpisah di 3 pecahan: Latar (pecahan I), Isi (pecahan II), Tanya (pecahan III).

Set A: Abstraction

Latar: “Di Menara Ukiran, sang Penempa menetapkan sebuah Cetak Biru Senjata: setiap senjata WAJIB memiliki kemampuan Menyerang, namun Cetak Biru itu tak pernah menjelaskan bagaimana cara menyerang.”
Isi: “Pedang menebas, busur melepaskan panah, tongkat memancarkan petir. Tetapi Cetak Biru itu sendiri tak pernah bisa ditempa menjadi senjata nyata.”
Tanya: “Dalam bahasa para penyihir kode, apakah nama Cetak Biru yang tak dapat diwujudkan langsung itu?”
Pilihan: A. Objek konkret | B. Kelas abstrak (benar) | C. Variabel global | D. Konstruktor

Set B: Polymorphism

Latar: “Penjaga gerbang meneriakkan satu mantra yang sama: ‘SERANG!’”
Isi: “Prajurit mengayunkan gada sekali. Elit mengayun dua kali beruntun. Raja menghantam tanah hingga bergetar. Mantra tetap satu, namun wujud tindakan berbeda sesuai penerimanya.”
Tanya: “Apakah nama prinsip ketika satu perintah menghasilkan perilaku berbeda pada wujud yang berbeda?”
Pilihan: A. Enkapsulasi | B. Pewarisan saja | C. Polimorfisme (benar) | D. Abstraksi

Set C: Gabungan

Latar: “Pecahan pertama berbunyi: ‘Setiap goblin WAJIB bisa bergerak dan menyerang.’ Pecahan kedua berbunyi: ‘Prajurit, Elit, dan Raja menentukan sendiri cara mereka menyerang.’”
Isi: “Pecahan pertama hanya menetapkan kewajiban tanpa menjelaskan caranya. Pecahan kedua mengisi caranya, berbeda-beda untuk tiap goblin.”
Tanya: “Apa nama untuk pecahan pertama dan pecahan kedua secara berurutan?”
Pilihan: A. Polimorfisme, lalu Abstraksi | B. Enkapsulasi, lalu Pewarisan | C. Abstraksi, lalu Polimorfisme (override method) (benar) | D. Konstruktor, lalu Destruktor

Posisi jawaban diacak tiap sesi. Soal bisa disesuaikan dengan arahan dosen.

4.6 Progression
Splash → Menu Utama → Mulai Petualangan (atau Pilih Level)
→ Hutan Hollow (tutorial di awal) → Level 1 / 2 / 3 dikerjakan dalam urutan bebas
→ Tiga pecahan → Altar → Teka-teki → Kunci → Peti → Ending
Semua level terbuka sejak awal. Pilih Level hanya menampilkan status tiap level (belum / selesai) dan memunculkan pemain di titik masuk zona yang dipilih.
Pemain disarankan, tetapi tidak dipaksa, mengerjakan dari Level 1.
Toko Orrin dan Catatan dibuka dari dalam gubuk dan menu. 5. UX / UI / Audio
5.1 Alur layar keseluruhan
[Splash / Logo] → [Menu Utama] ─┬─ Mulai Petualangan → Hutan Hollow
├─ Pilih Level → pilih zona → Hutan Hollow
├─ Cara Bermain
├─ Catatan Penempa
├─ Pengaturan (volume, fullscreen)
└─ Tentang
Hutan Hollow ↔ [Interior Gubuk + Toko Orrin]
Hutan Hollow → Pause (Lanjut / Cara Bermain / Catatan / Pengaturan / Menu Utama)
Hutan Hollow → [Panel Level Selesai] (popup saat zona bersih)
Hutan Hollow → [Kalah] → Coba Lagi
Hutan Hollow → [Ending] → Menu Utama
5.2 Halaman masuk (Splash dan logo)
Layar klik awal: “Klik untuk mulai”. Wajib di web karena audio browser baru boleh jalan setelah interaksi pertama.
Logo pengembang/kelompok (fade in dan out, ±2 detik).
Logo ELYS di atas latar diorama hutan berkabut, kabut bergerak, musik tema pelan. Bisa dilewati dengan klik atau tombol apa saja.
Transisi ke Menu Utama.
5.3 Menu Utama

Latar adalah diorama 3D sungguhan (Hutan Hollow pagi hari) dengan kamera bergerak lambat.

Tombol Fungsi
Mulai Petualangan Mulai dari titik awal
Pilih Level Tampilkan 3 level, mulai di titik masuk zona pilihan
Cara Bermain Halaman panduan (5.5)
Catatan Penempa Daftar catatan yang sudah terbuka
Pengaturan Slider volume BGM dan SFX, tombol fullscreen
Tentang Nama dan foto pengembang dan dosen, kredit aset

Tidak ada tombol “Keluar” karena ini versi web.

5.4 Tutorial interaktif

Tutorial berjalan di Hutan Hollow sebagai prompt bertahap di atas layar dengan ikon tombol. Tiap langkah selesai otomatis saat aksi dilakukan. Ada tombol Lewati Tutorial yang bisa ditekan kapan saja.

Langkah Prompt Selesai saat
1 “Gerakkan L dengan W A S D, putar kamera dengan mouse” Pemain bergerak ±3 m
2 “Dekati goblin Lv.1 dan serang dengan J atau klik kiri” Prajurit pertama terkena pukulan
3 “Hindari ayunannya saat tubuhnya berkedip merah” Pemain lolos dari satu serangan
4 “Ambil item yang jatuh dengan mendekatinya” Item pertama terambil
5 “Tekan Q untuk minum ramuan” (diberi 1 ramuan gratis) Pemain menekan Q
6 “Masuk gubuk dengan E, bicara dengan Orrin dan buka toko” Toko dibuka dan ditutup

Prajurit pertama untuk tutorial dibuat lebih lemah (HP 10) dan tidak menyerang lebih dulu, supaya pemain belajar dengan aman.

5.5 Halaman Cara Bermain

Halaman statis (dari Menu Utama dan Pause) dengan 4 tab:

Kontrol: gambar keyboard dan fungsinya.
Tujuan: kumpulkan 3 pecahan, jawab teka-teki, buka peti.
Atribut dan Item: HP, Koin, XP, 3 collectible, booster, dan ciri tiga goblin.
Teka-teki Rune: cara menyusun pecahan dan menjawab, plus tips membaca Catatan.
5.6 Pilih Level

Tiga node di atas ilustrasi peta hutan (Jalan Berkabut, Sarang Goblin, Fajar di Gubuk Tua). Tiap node menunjukkan status (belum / selesai) dan jenis goblin penjaganya. Semua node terbuka. Di bawah: indikator pecahan rune (0 sampai 3).

5.7 HUD
Kiri atas: bar HP dan level karakter.
Kanan atas: koin dan bar XP.
Tengah atas: progres zona (“Prajurit 3/5, Elit 0/3, Raja 0/1”).
Kiri bawah: ikon 3 pecahan rune (abu-abu, lalu menyala jika dimiliki).
Tengah bawah: prompt interaksi (“E: Masuk gubuk”).
Di atas kepala goblin: label jenis dan level.
5.8 Layar akhir
Panel Level Selesai (popup): muncul saat zona bersih, berisi XP, koin, item, dan pecahan yang didapat, plus tombol Lanjut.
Kalah: teks singkat dan tombol Coba Lagi.
Ending: peti terbuka, kabut naik, kredit singkat, tombol kembali ke Menu Utama.
5.9 Tentang (About)

Foto dan nama setiap pengembang, foto dan nama dosen (syarat PDF), lalu daftar kredit aset (dari CREDITS.md).

5.10 Feedback
Aksi Visual Audio
Serang Efek tebas, shake kecil SFX tebas
Kena hit Flash putih, knockback SFX hit
Goblin berkedip merah Tubuh berkedip merah SFX peringatan
Goblin mati Asap dan partikel, drop berkilau SFX mati
Ambil item Kilau, ikon terbang ke HUD SFX pickup
Jual/tukar Angka koin naik SFX koin
Level up Cahaya dari karakter Jingle pendek
Pecahan diambil Ikon menyala, cahaya hutan bergeser SFX magis, SFX gulungan
Rune menyatu Cahaya bersinar SFX magis
Jawaban benar Kunci menempa, ledakan cahaya Jingle sukses
Jawaban salah Rune bergetar, tepi layar merah SFX buzz
Peti terbuka Cahaya, kabut naik Musik klimaks
5.11 Audio
BGM: menu (tenang, tema Elys), hutan (satu lagu dengan nuansa yang berubah mengikuti jumlah pecahan: tenang, tegang ringan, hangat), ending (pendek).
SFX: langkah, tebas, hit, goblin grunt, hantaman Raja, pickup, koin, klik UI, pintu gubuk, gulungan, rune, peti, level up.
Format OGG. Lisensi free atau buatan sendiri.
5.12 Aksesibilitas dasar

Slider volume terpisah untuk BGM dan SFX, font minimal 16 px dengan kontras tinggi, kontrol alternatif panah selain WASD, tidak ada kilatan cepat berlebihan, teks teka-teki bisa dibaca ulang kapan saja.

6. Technical Design (Godot)
   6.1 Versi dan target
   Godot 4.7.2. Renderer Compatibility (OpenGL 3.3 / WebGL 2.0), satu-satunya pilihan untuk web. Jangan pindah ke Forward+ atau Mobile.
   Resolusi dasar 1280x720, stretch mode canvas_items, aspect keep.
   Ekspor web single-thread, dijalankan lewat web server (bukan dibuka langsung dari folder).
   6.2 Struktur project
   res://
   autoload/ game_state.gd, level_manager.gd, quest_manager.gd,
   audio_manager.gd, tutorial_manager.gd
   scenes/
   menus/ splash, main_menu, level_select, how_to_play, codex,
   settings, about, end_lose, ending, shop, pause
   levels/ hollow_level.tscn (membungkus map_a.tscn)
   maps/ map_a.tscn, hut_interior.tscn
   actors/ player.tscn, enemy.tscn (basis abstrak),
   goblin_prajurit.tscn, goblin_elit.tscn, goblin_raja.tscn, keeper.tscn
   objects/ pickup.tscn, rune_pedestal.tscn, altar.tscn, chest.tscn
   ui/ hud.tscn, rune_puzzle.tscn, dialog.tscn, tutorial_prompt.tscn
   scripts/ camera_follow.gd, player.gd, enemy.gd, scatter.gd,
   auto_collision.gd, auto_collision_trunk.gd, day_night_manager.gd
   data/ items/_.tres, questions/_.tres, enemies/_.tres, codex/_.tres
   assets/ sprites, models, textures, audio, fonts, vfx
   6.3 Teknik visual HD-2D untuk web (Compatibility)
   Efek yang diinginkan Teknik aman untuk web
   Kabut Fog biasa di Environment (warna keunguan, density rendah), plus plane kabut bertekstur noise yang bergerak pelan
   Batas area gelap Fog menebal ke tepi, vignette (ColorRect shader di CanvasLayer), OuterGround digelapkan, tebing dan pohon rapat
   Sinar matahari tembus pohon 3-5 plane miring bertekstur gradient, material Unshaded + Blend Add
   Pergantian cahaya DayNightManager: preset pagi, siang, sore, fajar (warna cahaya, fog, ambient) yang berubah saat pecahan diambil
   Bloom Glow di Environment, plus sprite additive di sumber cahaya
   Ambient occlusion Tidak ada SSAO di Compatibility. Pakai vertex color gelap dan clutter di kaki objek
   Bayangan DirectionalLight3D dengan shadow, 2 splits, jarak maksimal 30-40 m. Bayangan karakter dari sprite (Alpha Cut = Discard)
   Cahaya lokal Batasi OmniLight3D (misalnya jendela gubuk), sisanya sprite glow
   Partikel GPUParticles3D ringan (kunang-kunang), total ±100 partikel
   Rumput dan clutter MultiMesh, maksimal ±500 instance, tanpa collision, Cast Shadow mati
   Lingkaran rune Quad transparan di Y 0.02 (Decal tidak jalan di Compatibility)

Efek yang tidak dipakai karena tidak berefek di Compatibility: SSAO, SDFGI, Volumetric Fog.

Aturan sprite: billboard = Y-Billboard, texture_filter = Nearest, alpha_cut = Discard, shaded = true, pixel_size = 0.02, cast_shadow = On. Hero memakai 4 arah, goblin memakai 4 arah (walk, attack, death). Ukuran frame berbeda antar-animasi, jadi posisi kaki disamakan lewat offset per animasi di skrip.

Kamera: orbit mouse. Sudut awal pitch -26°, yaw 20°, jarak 10, FOV 30. Mendongak sampai -35° dengan jarak otomatis memendek agar tidak tembus tanah. Kamera mengikuti pemain sampai ke pojok peta (tanpa batas kamera).

Performa web: tekstur maksimal 512 px (kecuali latar), audio OGG, hindari lightmap resolusi tinggi, collision convex diganti BoxShape3D jika terasa lag, uji di Chrome dan Firefox.

6.4 Autoload (singleton)
Autoload Tugas
GameState HP, koin, XP, level, inventory, booster. Memancarkan sinyal ke HUD
LevelManager Status zona (belum/selesai), jumlah goblin tersisa per zona, pindah ke interior gubuk dan kembali, titik masuk zona
QuestManager Pecahan rune (3 bool), set pertanyaan terpilih, status kunci dan peti, catatan terbuka
AudioManager BGM, SFX, volume
TutorialManager Urutan langkah tutorial, status selesai atau lewati
6.5 Pola komunikasi
Signal untuk UI (hp_changed, coins_changed, zone_progress, rune_collected, tutorial_step_done). UI tidak polling di \_process.
Group "enemy" dan "player" untuk pencarian target.
Direct call hanya dari parent ke child.
Hanya GameState yang boleh mengubah atribut.
Polimorfisme di kode: Enemy memanggil attack() tanpa peduli jenisnya. Tiap goblin meng-override-nya.
6.6 Data
Data Format
Item ItemData Resource (.tres)
Pertanyaan QuestionData Resource: parts[3], options[4], correct_index, hint_remove_index
Statistik musuh EnemyData Resource (HP, damage, speed, deteksi, cooldown, XP, drop)
Catatan CodexEntry Resource: judul, teks fantasi, terjemahan, syarat terbuka
Progress Disimpan di memori selama sesi. Save ke user:// opsional
6.7 Input map, collision, aturan kode

Input map: left, right, up, down, jump, attack, interact, use_potion, pause.

Collision layer:

Layer Nama
1 World
2 Player
3 Enemy
4 PlayerHitbox
5 EnemyHitbox
6 Pickup
7 Interactable

Collision peta: lantai memakai StaticBody3D dengan BoxShape3D. Tebing dan batu memakai skrip auto_collision.gd (bentuk convex dari mesh). Pohon memakai auto_collision_trunk.gd (hanya bagian batang). Landmark (gubuk, alas peti, batu altar) memakai kotak sederhana. Dinding tak terlihat setinggi 4 m di empat sisi. Jangan Regenerate scatter setelah collision dibuat.

Aturan kode:

File dan variabel snake_case, kelas PascalCase, konstanta UPPER_CASE.
Satu script satu tanggung jawab, usahakan maksimal ±200 baris.
Hindari angka ajaib, pindahkan ke const atau Resource.
Tidak ada print debug yang tersisa di build final.
6.8 Export Web

Preset Web (Runnable), renderer Compatibility, Thread Support mati, ekspor ke index.html. Uji lewat server lokal (misalnya XAMPP Apache) dan webhost lab. Tiap ekspor ulang, tekan Ctrl + F5 di browser. Jika muncul error MIME, tambahkan .htaccess dengan AddType application/wasm .wasm. Pastikan fullscreen berfungsi lewat tombol (butuh aksi pemain) dan audio baru mulai setelah klik pertama.

7. Production Plan
   7.1 Milestone (urutan, tanpa tanggal)
   Milestone Kondisi tercapai Status
   M1 Prototype Peta A tampil dengan lighting dasar, L bisa berjalan, ekspor web berhasil Tercapai
   M2 Vertical slice Tiga goblin berfungsi, serang, HP, drop, tutorial, zona Level 1 selesai dengan pecahan I Berikutnya
   M3 Alpha Interior gubuk dan toko, XP dan level, ketiga zona, teka-teki rune berfungsi, semua menu
   M4 Beta Peti, ending, audio lengkap, semua catatan, pergantian cahaya
   M5 Release Bug fix, balancing, build final, semua luaran wajib
   7.2 Urutan pengerjaan
   Setup project (Compatibility), GitHub, Trello, input map, kamera, ekspor web percobaan. (selesai)
   Peta A: terrain, tebing, gubuk, pohon, batu, dekorasi, lighting, fog, area luar digelapkan.
   Fondasi: collision layer, dinding tak terlihat, collision landmark, group enemy dan player.
   L: gerak, lompat, serang, HP, animasi.
   Kelas Enemy abstrak, lalu Goblin Prajurit, Elit, dan Raja (AI, damage, drop, pickup, respawn Prajurit).
   GameState, HUD, XP dan level.
   Interior gubuk, Kakek Orrin, dialog, toko.
   Tutorial dan zona Level 1 lengkap.
   Pedestal rune, QuestManager, Catatan, UI puzzle rune, altar.
   Peti dan ending, pergantian cahaya per pecahan.
   Splash, Menu Utama, Pilih Level, Cara Bermain, Pengaturan, About, layar kalah.
   Audio dan efek (sinar matahari, kunang-kunang, vignette).
   Testing, balancing, tuning visual akhir.
   Build final dan semua luaran wajib.
   7.3 Urutan pemotongan scope (jika waktu mepet)
   Shader tilt-shift dan rumput bergoyang
   Respawn Goblin Prajurit
   Variasi pertanyaan (pakai 1 set saja)
   Animasi bicara Orrin
   Interior gubuk jadi panel dialog dan toko di depan pintu (tanpa ruangan terpisah)
   Berkat Kabut dan serangan area Raja disederhanakan

Tidak boleh dipotong: 3 level (zona), 3 atribut, 3 collectible, ekonomi, audio, struktur menu sesuai PDF, tutorial, About, dan teka-teki rune.

7.4 Pipeline aset
Aset Sumber Format
Sprite hero Pack free/CC0 atau buat sendiri PNG per frame, 4 arah
Sprite goblin Dihasilkan dengan alat AI lalu dipotong manual, varian Elit dan Raja lewat palette dan skala PNG per frame, 4 arah (walk, attack, death)
Model 3D Kenney Nature Kit (CC0), di-retexture glb
Tekstur ambientCG (CC0), dikecilkan PNG ≤ 512 px
Audio Freesound, Pixabay, Kenney, OpenGameArt OGG
UI, logo, font Buat sendiri / font free PNG, TTF
Foto About Pengembang dan dosen JPG/PNG ≤ 512 px

Semua aset dicatat di CREDITS.md dengan format: nama, pembuat, lisensi, link, tanggal download. Aset AI-generated diperbolehkan oleh PDF, tetapi tetap dicatat.

7.5 Manajemen proyek
Trello: kolom Backlog, To Do, Doing, Testing, Done. Invite semua anggota, dosen, dan asisten, lalu hubungkan ke GitHub.
GitHub (private): branch main (stabil) dan dev, commit kecil dan rutin, folder docs/ berisi GDD, instrumen uji, dan hasil uji.
Laporan progres: demo ke dosen/asisten sesuai jadwal kelas.
Backup: salin repo ke cloud secara berkala.
7.6 Risiko
Risiko Antisipasi
Efek web tidak seindah desktop Uji ekspor web tiap tahap, pakai teknik di 6.3
Sprite goblin AI tidak konsisten antar-frame dan arah Periksa frame satu per satu, perbaiki yang terpotong atau berubah skala, uji di engine
Goblin Raja terlalu sulit atau terlalu mudah Statistik di Resource EnemyData, mudah disetel saat balancing
Peta terasa kosong atau terlalu sesak Fokus kepadatan di area yang terlihat kamera, hutan jauh pakai scatter dan kabut
Pohon menutupi kamera orbit Pohon tinggi hanya di utara, barat, timur. Opsional transparan saat menghalangi
Build web terlalu besar atau lambat Kompres tekstur, OGG, batasi MultiMesh, shadow 2 splits
Scope bengkak Ikuti 7.3, tidak ada fitur baru setelah M3
Puzzle rune rumit Mulai dari versi klik-pilih urutan, drag-drop belakangan
Tenggat HKI dan dokumen mepet Mulai draf HKI jauh sebelum game selesai 8. Testing dan Release
8.1 Functional Test (developer)
ID Uji Hasil yang diharapkan
F01 Splash: klik awal, logo, lanjut ke menu Audio mulai setelah klik, bisa di-skip
F02 Semua tombol Menu Utama Masing-masing membuka layar yang benar
F03 Cara Bermain, 4 tab Semua tab tampil dan terbaca
F04 Tutorial langkah 1-6 Tiap langkah maju otomatis, Lewati Tutorial berfungsi
F05 Gerak, kamera orbit, lompat, flip sprite W menjauhi kamera, sprite menghadap sesuai arah
F06 Serang tiap jenis goblin HP turun, goblin mati, drop muncul
F07 Pola serangan Prajurit satu ayunan, Elit dua ayunan, Raja serangan area, masing-masing diawali kedip merah
F08 Goblin mengenai L HP turun, kebal 0.6 s
F09 Pilih lawan bebas Semua goblin sudah ada sejak awal, tiap goblin menampilkan label jenis dan level
F10 Pickup item Inventory dan HUD bertambah
F11 Pintu gubuk dan Orrin E membuka interior, bicara membuka toko, keluar kembali ke halaman gubuk
F12 Jual, tukar, beli Koin dan item berubah sesuai harga, batas booster terjaga
F13 XP dan level up Max HP dan damage naik, HP penuh
F14 Zona bersih Pedestal Rune aktif, panel Level Selesai muncul
F15 Ambil pecahan rune HUD menyala, Catatan terbuka, cahaya hutan bergeser
F16 Respawn Prajurit muncul kembali (maks 5), Elit dan Raja tidak
F17 Menu Catatan Hanya catatan yang terbuka yang bisa dibaca
F18 Susun rune salah/benar Salah ditolak, benar menampilkan teka-teki
F19 Jawab salah/benar Salah: -10 HP dan pilihan mati. Benar: kunci jatuh
F20 Gulungan Petunjuk Satu pilihan salah dihilangkan
F21 Buka peti tanpa/dengan kunci Tanpa kunci ditolak, dengan kunci ending berjalan
F22 HP = 0 Layar Kalah, Coba Lagi bangkit di titik awal, progress aman, goblin reset
F23 Pilih Level Status tiap level benar, pemain muncul di zona yang dipilih
F24 Batas area Pemain tidak bisa keluar peta, tepi peta gelap
F25 Pause Lanjut, Cara Bermain, Catatan, Pengaturan, Menu Utama berfungsi
F26 Slider volume dan fullscreen BGM dan SFX berubah terpisah, fullscreen berfungsi
F27 About Foto dan nama pengembang dan dosen tampil
F28 Build web di Chrome dan Firefox Berjalan tanpa error, performa stabil
8.2 Alpha Test (pemain)
Penguji: 5-10 orang yang belum pernah melihat game (teman kelas, kelompok lain).
Cara: pemain memainkan dari Splash sampai Ending tanpa dibantu. Developer hanya mengamati dan mencatat.
Instrumen (formulir singkat):
Apakah kontrol dan tujuan jelas setelah tutorial? (skala 1-5)
Apakah teka-teki rune bisa dimengerti? (1-5)
Tingkat kesulitan tiap zona (terlalu mudah, pas, terlalu sulit)
Apakah perbedaan ketiga goblin terasa jelas? (1-5)
Kejelasan materi Polymorphism dan Abstraction setelah membaca Catatan
Tampilan visual dan suasana (1-5)
Bug atau hal membingungkan (isian bebas)
Metrik: waktu menyelesaikan tiap level, urutan zona yang dipilih, jumlah kematian dan penyebabnya (goblin mana), jumlah jawaban salah, di langkah mana pemain macet.
Hasil dirangkum dan dimasukkan ke folder docs/ di GitHub.
8.3 Bug tracking dan balancing
Bug dicatat di Trello (kolom Testing) atau GitHub Issues dengan prioritas: Crash/blocker, Mayor, Minor.
Balancing pass: sesuaikan HP/damage goblin, drop rate, dan harga jika alpha test menunjukkan pemain terlalu cepat kaya atau terlalu sering kalah. Target: pemain rata-rata menyelesaikan satu level dalam 3-5 menit dan jarang mati lebih dari 3 kali per level. Goblin Raja boleh terasa sulit, tetapi harus bisa dikalahkan oleh pemain yang sudah menaikkan level dan menukar penguat.
8.4 Checklist rilis dan luaran wajib
Build web sudah dideploy ke webhost lab dan diuji
Full project di GitHub, termasuk aset final
GDD final
Instrumen Uji dan Hasil Uji (Functional dan Alpha) di repo
Poster digital A4
Video trailer ±5 menit
HKI (draft atau terbit sesuai aturan dosen)
CREDITS.md lengkap, dan kredit tampil di About

Pasca-rilis: tidak ada rencana patch. Jika ada perbaikan setelah penilaian, dicatat sebagai known issues di repo.

Lampiran: Matriks kepatuhan terhadap spesifikasi PDF

# Syarat PDF Pemenuhan di Elys

1 Genre bebas (bukan novel/endless runner) Action-adventure puzzle
2 2D atau 3D 2.5D (HD-2D)
3 Output Web Godot Web export, Compatibility
4 Keyboard/mouse/touch Keyboard dan mouse
5 Minimal 3 atribut HP, Koin, XP (plus level turunan)
6 Minimal 3 collectible yang bisa dikonversi Taring Goblin, Lempeng Besi, Kristal Kabut
7 In-game economy Jual, tukar jadi booster, beli, XP menjadi level
8 Audio dan musik BGM, SFX lengkap (lisensi free)
9 Aset berlisensi free/buatan sendiri/AI Dicatat di CREDITS.md
10 Minimal 3 level, cerita berkaitan materi 3 level berbentuk zona (Jalan Berkabut, Sarang Goblin, Fajar di Gubuk Tua) di satu peta, menyusun teka-teki Polymorphism dan Abstraction
11a Start Screen/Menu Splash dan Menu Utama
11b Level Select Pilih Level (bagian 5.6)
11c Game Session Hutan Hollow, level 1-3
11d End Session (menang/kalah) Panel Level Selesai, Kalah, Ending
11e About (nama dan foto pengembang + dosen) Ada (bagian 5.9)
12 Tidak dari nol, boleh template Pakai pack aset (Kenney, ambientCG) dan template gerak

Perubahan utama dari versi 1.2

Peta: dari 2 peta menjadi 1 peta (18 x 18 m) dengan area luar digelapkan. Peta B dihapus.
Musuh: slime dihapus, diganti 3 varian goblin (Prajurit, Elit, Raja) yang semuanya ada sejak awal di zona masing-masing. Item, XP, dan soal teka-teki ikut disesuaikan.
Gubuk: Kakek Orrin sekarang di dalam gubuk, dengan interior kecil sebagai tempat toko.
Level: tiga level kini berupa zona di satu peta. Pilih Level kupertahankan supaya syarat 11b di PDF tetap terpenuhi (semua level terbuka sejak awal).
Teknis: disesuaikan dengan kondisi project (Godot 4.7.2, kamera orbit, collision otomatis, efek yang tidak jalan di Compatibility) dan statusnya (M1 tercapai).
