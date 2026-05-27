# Panduan Pengujian BuwohApp (Frontend-Backend Integration)

Dokumen ini berisi langkah-langkah untuk menguji fitur-fitur yang telah diintegrasikan antara Frontend Flutter dan Backend Node.js.

## Persiapan Awal
Sebelum memulai, pastikan kondisi berikut terpenuhi:
1. **Backend Running**: Pastikan terminal backend menampilkan pesan `Server is running on http://192.168.1.10:5000`.
2. **Koneksi Jaringan**: HP/Emulator dan Laptop harus berada di jaringan Wi-Fi yang sama.
3. **Database**: Pastikan MySQL sudah aktif (XAMPP/Docker).

---

## 1. Pengujian Registrasi (Register)
Tujuan: Membuat akun baru di database.
- **Langkah**:
    1. Buka aplikasi, Anda akan diarahkan ke layar **Login**.
    2. Klik tombol **"Daftar"** di bagian bawah.
    3. Isi formulir pendaftaran:
        - Nama Lengkap (Contoh: "User Pengetesan")
        - Email (Contoh: "test@buwoh.com")
        - Kata Sandi (Contoh: "password123")
        - Konfirmasi Kata Sandi
    4. Klik tombol **"Daftar"**.
- **Hasil yang Diharapkan**:
    - Snackbox sukses muncul.
    - Anda otomatis diarahkan ke layar **Home (Dashboard)**.
    - Data muncul di tabel `User` di database.

## 2. Pengujian Login
Tujuan: Masuk ke aplikasi menggunakan akun yang sudah ada.
- **Langkah**:
    1. Jika sudah login, lakukan **Logout** terlebih dahulu (lihat langkah 3).
    2. Di layar Login, masukkan email dan password yang baru saja didaftarkan.
    3. Klik tombol **"Masuk"**.
- **Hasil yang Diharapkan**:
    - Loader muncul sebentar.
    - Anda berhasil masuk ke halaman **Home**.
    - Nama Anda muncul di bagian header dashboard ("Halo, User!").

## 3. Pengujian Logout
Tujuan: Keluar dari aplikasi dan menghapus sesi (token).
- **Langkah**:
    1. Dari halaman Home, klik ikon **Profil** di Bottom Navigation Bar (paling kanan).
    2. Scroll ke bawah dan klik tombol merah **"Logout"**.
    3. Konfirmasi pada dialog yang muncul.
- **Hasil yang Diharapkan**:
    - Sesi dihapus.
    - Anda diarahkan kembali ke layar **Login**.

## 4. Pengujian Create Event (Opsional)
Tujuan: Memverifikasi pengiriman data multipart ke server.
- **Langkah**:
    1. Di halaman Home, klik kartu **"Buat Acara"** (ikon plus).
    2. Isi detail acara (Judul, Tipe, Tanggal, dll).
    3. Klik **"Simpan Acara"**.
- **Hasil yang Diharapkan**:
    - Acara tersimpan dan muncul di daftar **"Acara Saya"** di dashboard.

---

## Troubleshooting
Jika terjadi error "Connection Refused":
1. Jalankan `ipconfig` di terminal laptop Anda.
2. Pastikan IP Address di `frontend/lib/config/api_config.dart` sama dengan IP laptop Anda.
3. Restart server backend.
