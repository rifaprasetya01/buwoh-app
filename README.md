# Buwoh App 🎊

Buwoh App adalah aplikasi inovatif untuk mendigitalisasi tradisi hajatan dan "buwuh" (sumbangan acara) di Indonesia. Aplikasi ini membantu tuan rumah mengelola acara, undangan, dan merekap sumbangan tamu secara digital.

Proyek ini terdiri dari dua bagian utama:
1. **Frontend:** Dibangun menggunakan Flutter (Dart)
2. **Backend:** Dibangun menggunakan Node.js (Express), TypeScript, dan Prisma ORM dengan database MySQL.

---

## 📋 Persyaratan Sistem (Prerequisites)

Sebelum mulai menjalankan proyek ini, pastikan komputer Anda sudah terinstal perangkat lunak berikut:

1. **Node.js & npm** (Minimal v18 disarankan) - [Download Node.js](https://nodejs.org/)
2. **Flutter SDK** (Minimal v3.11.0) - [Download Flutter](https://docs.flutter.dev/get-started/install)
3. **MySQL Server** (Bisa menggunakan XAMPP, Laragon, MAMP, atau MySQL standalone)
4. **Git** - [Download Git](https://git-scm.com/)
5. (Opsional tapi disarankan) **Android Studio** atau **VS Code** beserta ekstensi Flutter/Dart.

---

## 🚀 Cara Setup dan Menjalankan Proyek

Ikuti langkah-langkah di bawah ini secara berurutan.

### 1. Kloning Repositori
Buka terminal/command prompt Anda, dan jalankan:
```bash
git clone <URL_GITHUB_ANDA>
cd buwoh-app
```

### 2. Setup Database & Backend
Pastikan server MySQL Anda (misal via XAMPP) sudah berjalan.

```bash
# Masuk ke direktori backend
cd backend

# Instal semua dependensi Node.js
npm install
```

**Konfigurasi Environment Backend:**
1. Buat file baru bernama `.env` di dalam folder `backend/` (Anda bisa menyalin dari `.env.example` jika ada).
2. Isi file `.env` dengan konfigurasi berikut:
   ```env
   # Ganti 'root' dan 'password' sesuai dengan konfigurasi MySQL Anda
   # Format: mysql://USER:PASSWORD@HOST:PORT/NAMA_DATABASE
   DATABASE_URL="mysql://root:@localhost:3306/buwoh_db"
   
   # Secret key bebas (untuk JWT Token)
   JWT_SECRET="rahasia_super_aman_123"
   
   PORT=3000
   ```
3. Sinkronisasi database menggunakan Prisma:
   ```bash
   npx prisma generate
   npx prisma db push
   ```
4. Jalankan server Backend:
   ```bash
   npm run dev
   ```
*Jika berhasil, backend akan menyala dan mendengarkan di port 3000.*

---

### 3. Setup Frontend (Aplikasi Mobile)
Buka tab terminal baru (biarkan terminal backend tetap berjalan).

```bash
# Masuk ke direktori frontend
cd frontend

# Unduh semua dependensi Flutter
flutter pub get
```

**Konfigurasi IP Backend:**
Karena aplikasi berjalan di HP atau Emulator, `localhost` tidak akan mengarah ke komputer Anda. Anda harus mengubah alamat IP.
1. Buka file `frontend/lib/config/api_config.dart`.
2. Ubah `baseUrl` sesuai dengan IP komputer Anda atau Emulator:
   - Jika menggunakan **Android Emulator bawaan**, gunakan IP `10.0.2.2`:
     ```dart
     static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
     ```
   - Jika menggunakan **HP Asli (Fisik) via Wi-Fi**, gunakan IPv4 komputer Anda (contoh `192.168.1.xxx`):
     ```dart
     static const String baseUrl = 'http://192.168.1.15:3000/api/v1';
     ```

**Jalankan Aplikasi:**
Pastikan Emulator sudah menyala atau HP Android/iOS Anda sudah terhubung via USB Debugging.
```bash
flutter run
```

---

## 🛠️ Ringkasan Stack Teknologi
- **Mobile App:** Flutter, Provider (State Management), Material 3.
- **Backend:** Node.js, Express, TypeScript, Zod (Validasi).
- **Database:** MySQL via Prisma ORM.

## 🤝 Kontribusi
Pastikan membuat branch baru (misal `feature/nama-fitur`) dari branch `master-dev` jika ingin menambahkan fitur baru.

*Selamat mencoba dan mengembangkan Buwoh App!* 🎊
