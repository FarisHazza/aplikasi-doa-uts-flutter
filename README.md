# Aplikasi Kumpulan Doa Harian (`aplikasi_doa_uts`)

Proyek ini dikembangkan untuk memenuhi tugas **Ujian Tengah Semester (UTS) Pemrograman Mobile** pada Jurusan Teknik Informatika, Fakultas Sains dan Teknologi, UIN Maulana Malik Ibrahim Malang.

- **Nama:** Faris Hazza
- **NIM:** 250605110193
- **Kelas:** Pemrograman Mobile - B

---

## 1. Deskripsi Singkat Aplikasi
**Aplikasi Kumpulan Doa Harian** adalah aplikasi *mobile* berbasis Flutter dan bahasa pemrograman Dart yang menyajikan daftar bacaan doa sehari-hari secara dinamis melalui REST API publik (`https://doa-doa-api-ahmadramadhan.fly.dev/api`). Aplikasi ini menampilkan judul doa, teks bacaan dalam bahasa Arab (`ayat`), transliterasi huruf Latin (`latin`), serta terjemahan bahasa Indonesia (`artinya`) dengan antarmuka Material Design 3 yang bersih dan mudah dibaca.

## 2. Fitur Utama
1. **Pemuatan Data Dinamis (*Live API Fetching*):** Mengambil daftar doa secara *real-time* dari *endpoint* REST API melalui protokol HTTP GET saat aplikasi dijalankan.
2. **Pencarian Doa Instan (*Search & Filter*):** Memungkinkan pengguna mencari dan memfilter doa secara langsung berdasarkan judul doa maupun kata kunci pada arti terjemahan.
3. **Daftar Doa Interaktif (`ListView.builder` & `Card`):** Menampilkan daftar doa secara efisien (*lazy loading*) lengkap dengan nomor urut (`CircleAvatar`), teks Arab rata kanan (`TextDirection.rtl`), dan cuplikan terjemahan.
4. **Halaman Detail Bacaan Lengkap (`HalamanDetailDoa`):** Navigasi halaman (`Navigator.push`) untuk menampilkan bacaan Arab berukuran besar, teks transliterasi Latin bercetak miring, dan terjemahan bahasa Indonesia secara penuh.
5. **Penanganan Status Jaringan (*Loading*, *Error*, & *Refresh*):** Dilengkapi indikator pemuatan (`CircularProgressIndicator`), fitur tarik untuk memuat ulang (*Pull-to-Refresh* / `RefreshIndicator`), serta tombol *Coba Lagi* apabila koneksi ke server mengalami kendala atau *timeout*.

## 3. Teknologi dan Package yang Digunakan
- **Framework:** Flutter (Material Design 3)
- **Bahasa Pemrograman:** Dart
- **REST API Endpoint:** `https://doa-doa-api-ahmadramadhan.fly.dev/api`
- **Package & Pustaka:**
  - `http: ^1.6.0` — Menangani permintaan HTTP GET asinkron ke server API.
  - `dart:convert` — Mendekode *byte* UTF-8 (`utf8.decode`) agar karakter huruf Arab tampil akurat serta mengonversi respons JSON (`jsonDecode`).

## 4. Struktur Berkas Utama
```text
aplikasi_doa_uts/
├── android/app/src/main/AndroidManifest.xml  # Konfigurasi izin akses internet Android
├── lib/
│   └── main.dart                             # Kode utama (UI, pemanggilan API, & navigasi)
├── pubspec.yaml                              # Konfigurasi dependensi package (http)
└── README.md                                 # Dokumentasi repositori proyek
