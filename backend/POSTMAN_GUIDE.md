# 📮 Panduan Testing API Buwoh di Postman

> Dokumen ini berisi panduan langkah-demi-langkah untuk menguji API Platform Buwoh menggunakan **Postman**. Kita akan mensimulasikan skenario nyata: dari registrasi user, membuat acara, hingga proses pengajuan dan persetujuan tamu.

---

## 📋 Daftar Isi

1. [Persiapan Awal](#-1-persiapan-awal)
2. [Skenario Simulasi](#-2-skenario-simulasi)
3. [Step 1 — Registrasi User A (Pemilik Acara)](#-step-1--registrasi-user-a-pemilik-acara)
4. [Step 2 — Registrasi User B (Calon Tamu)](#-step-2--registrasi-user-b-calon-tamu)
5. [Step 3 — Login User A](#-step-3--login-user-a)
6. [Step 4 — Cek Session / Get Me](#-step-4--cek-session--get-me)
7. [Step 5 — Lihat Kategori Acara & Bawaan](#-step-5--lihat-kategori-acara--bawaan)
8. [Step 6 — User A Buat Acara Baru](#-step-6--user-a-buat-acara-baru)
9. [Step 7 — User A Publish Acara](#-step-7--user-a-publish-acara)
10. [Step 8 — Lihat Daftar Acara (Publik)](#-step-8--lihat-daftar-acara-publik)
11. [Step 9 — Lihat Detail Acara](#-step-9--lihat-detail-acara)
12. [Step 10 — Login User B](#-step-10--login-user-b)
13. [Step 11 — User B Daftar Jadi Tamu](#-step-11--user-b-daftar-jadi-tamu)
14. [Step 12 — User A Lihat Daftar Tamu](#-step-12--user-a-lihat-daftar-tamu)
15. [Step 13 — User A Terima Pengajuan Tamu](#-step-13--user-a-terima-pengajuan-tamu)
16. [Step 14 — Cek Notifikasi](#-step-14--cek-notifikasi)
17. [Bonus: Skenario Tolak & Error](#-bonus-skenario-tolak--error)
18. [Tips Postman](#-tips-postman)

---

## 🔧 1. Persiapan Awal

### Pastikan Server Berjalan

```bash
# Di terminal, masuk ke folder backend
cd backend

# Jalankan server
npm run dev
```

Server akan jalan di `http://localhost:3000`. Semua request akan menggunakan base URL:

```
http://localhost:3000/api/v1
```

### Setup Postman

1. Buka Postman
2. Buat **Collection** baru, beri nama: `Buwoh API`
3. Set **variable** di level Collection:
   - `base_url` = `http://localhost:3000/api/v1`
   - `token_a` = *(kosongkan dulu, akan diisi nanti)*
   - `token_b` = *(kosongkan dulu, akan diisi nanti)*
   - `event_id` = *(kosongkan dulu)*
   - `guest_id` = *(kosongkan dulu)*

> 💡 **Cara set variable:** Klik Collection → tab **Variables** → tambahkan variable di atas.

### Header Default

Untuk semua request yang mengirim data (POST/PUT/PATCH), set header:

| Key | Value |
|-----|-------|
| `Content-Type` | `application/json` |

Untuk request yang butuh login, tambahkan:

| Key | Value |
|-----|-------|
| `Authorization` | `Bearer {{token_a}}` atau `Bearer {{token_b}}` |

---

## 🎬 2. Skenario Simulasi

Kita akan simulasi cerita berikut:

> **Pak Budi** (User A) membuat acara pernikahan anaknya. Setelah dipublish, **Ibu Sari** (User B) melihat acara tersebut dan mendaftarkan diri sebagai tamu dengan membawa beras 5 kg dan uang Rp 50.000. Pak Budi kemudian menerima pengajuan Ibu Sari.

---

## 📝 Step 1 — Registrasi User A (Pemilik Acara)

Daftarkan Pak Budi sebagai pemilik acara.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/auth/register` |
| **Body** | raw → JSON |

### Body (JSON):

```json
{
  "name": "Pak Budi Santoso",
  "email": "budi@email.com",
  "password": "password123",
  "phoneNumber": "081234567890",
  "address": "Jl. Merdeka No. 1, Yogyakarta"
}
```

### ✅ Expected Response (201 Created):

```json
{
  "success": true,
  "message": "Registrasi berhasil.",
  "data": {
    "user": {
      "id": "1",
      "name": "Pak Budi Santoso",
      "email": "budi@email.com",
      "phoneNumber": "081234567890",
      "address": "Jl. Merdeka No. 1, Yogyakarta",
      ...
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### 🔑 Simpan Token

**Copy** nilai `token` dari response, lalu:
1. Buka tab **Variables** di Collection
2. Paste ke `token_a` (kolom **Current Value**)

> 💡 **Atau otomatis via script:** Buka tab **Scripts → Post-response** dan tambahkan:
> ```javascript
> const res = pm.response.json();
> if (res.data && res.data.token) {
>     pm.collectionVariables.set("token_a", res.data.token);
> }
> ```

---

## 📝 Step 2 — Registrasi User B (Calon Tamu)

Daftarkan Ibu Sari sebagai calon tamu.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/auth/register` |

### Body (JSON):

```json
{
  "name": "Ibu Sari Wulandari",
  "email": "sari@email.com",
  "password": "password123",
  "phoneNumber": "081234567891",
  "address": "Jl. Kenanga No. 45, Semarang"
}
```

### ✅ Expected Response (201):

Sama seperti Step 1. **Simpan token ke `token_b`**.

> Post-response script:
> ```javascript
> const res = pm.response.json();
> if (res.data && res.data.token) {
>     pm.collectionVariables.set("token_b", res.data.token);
> }
> ```

---

## 📝 Step 3 — Login User A

Kalau token sudah expired atau ingin test login secara terpisah.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/auth/login` |

### Body (JSON):

```json
{
  "email": "budi@email.com",
  "password": "password123"
}
```

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Login berhasil.",
  "data": {
    "user": {
      "id": "1",
      "name": "Pak Budi Santoso",
      "email": "budi@email.com",
      ...
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Update `token_a`** dengan token baru.

### ❌ Test Error — Password Salah:

```json
{
  "email": "budi@email.com",
  "password": "salahpassword"
}
```

Response: `401 Unauthorized` — `"Email atau password salah."`

---

## 📝 Step 4 — Cek Session / Get Me

Memastikan token valid dan mendapatkan data user yang sedang login.

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/auth/me` |
| **Authorization** | `Bearer {{token_a}}` |

> ⚠️ **PENTING:** Di tab **Authorization**, pilih type **Bearer Token**, lalu isi dengan `{{token_a}}`

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Data user berhasil diambil.",
  "data": {
    "id": "1",
    "name": "Pak Budi Santoso",
    "email": "budi@email.com",
    "phoneNumber": "081234567890",
    "address": "Jl. Merdeka No. 1, Yogyakarta",
    "isActive": true,
    "createdAt": "2026-04-26T..."
  }
}
```

### ❌ Test Error — Tanpa Token:

Hapus header Authorization. Response: `401` — `"Akses ditolak. Token tidak ditemukan."`

### ❌ Test Error — Token Asal:

Set Authorization ke `Bearer tokenasal123`. Response: `401` — `"Token tidak valid."`

---

## 📝 Step 5 — Lihat Kategori Acara & Bawaan

Sebelum buat acara, lihat dulu kategori yang tersedia.

### 5a. Kategori Acara

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/event-categories` |

**Tidak perlu token** (endpoint publik).

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Daftar kategori acara berhasil diambil.",
  "data": [
    { "id": 1, "name": "Aqiqah", ... },
    { "id": 2, "name": "Khitan", ... },
    { "id": 3, "name": "Pernikahan", ... },
    { "id": 4, "name": "Sunatan", ... },
    { "id": 5, "name": "Syukuran", ... }
  ]
}
```

> 📌 **Catat** `id` untuk Pernikahan (biasanya `3`). Kita akan pakai di Step 6.

### 5b. Kategori Bawaan

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/gift-categories` |

### ✅ Expected Response (200):

```json
{
  "data": [
    { "id": 1, "name": "Beras", "unit": "kg", "isMonetary": false },
    { "id": 2, "name": "Gula", "unit": "kg", "isMonetary": false },
    ...
    { "id": 4, "name": "Minyak Goreng", "unit": "liter", ... },
    { "id": 10, "name": "Uang", "unit": "Rp", "isMonetary": true },
    ...
  ]
}
```

> 📌 **Catat** `id` untuk Beras dan Uang. Akan dipakai saat User B mendaftar tamu.

---

## 📝 Step 6 — User A Buat Acara Baru

Pak Budi membuat acara pernikahan anaknya.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/events` |
| **Authorization** | `Bearer {{token_a}}` |

### Body (JSON):

```json
{
  "eventCategoryId": 3,
  "title": "Resepsi Pernikahan Anak Pak Budi",
  "description": "Menikahkan putra pertama kami, Andi Santoso, dengan Dewi Lestari. Mohon doa restu.",
  "locationName": "Gedung Serbaguna Yogyakarta",
  "locationAddress": "Jl. Solo Km 5, Caturtunggal, Depok, Sleman, Yogyakarta 55281",
  "locationLat": -7.7956,
  "locationLng": 110.3695,
  "startDatetime": "2026-06-15T08:00:00.000Z",
  "endDatetime": "2026-06-15T15:00:00.000Z",
  "maxGuests": 50
}
```

> ⚠️ Sesuaikan `eventCategoryId` dengan id "Pernikahan" dari Step 5a.

### ✅ Expected Response (201):

```json
{
  "success": true,
  "message": "Acara berhasil dibuat.",
  "data": {
    "id": "1",
    "title": "Resepsi Pernikahan Anak Pak Budi",
    "status": "draft",
    "eventCategory": {
      "id": 3,
      "name": "Pernikahan"
    },
    ...
  }
}
```

> 📌 **Simpan `id` acara** ke variable `event_id`. Contoh: `1`
>
> Post-response script:
> ```javascript
> const res = pm.response.json();
> if (res.data && res.data.id) {
>     pm.collectionVariables.set("event_id", res.data.id);
> }
> ```

⚠️ **Perhatikan:** Status acara masih `"draft"`. Belum bisa dilihat publik dan belum bisa menerima tamu!

---

## 📝 Step 7 — User A Publish Acara

Ubah status dari `draft` ke `published` agar acara bisa dilihat dan menerima tamu.

| Setting | Value |
|---------|-------|
| **Method** | `PATCH` |
| **URL** | `{{base_url}}/events/{{event_id}}/status` |
| **Authorization** | `Bearer {{token_a}}` |

### Body (JSON):

```json
{
  "status": "published"
}
```

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Status acara berhasil diperbarui.",
  "data": {
    "id": "1",
    "status": "published",
    ...
  }
}
```

> 🔔 **Di balik layar:** Sistem otomatis mengirim notifikasi **balas budi** ke semua user yang pernah hadir di acara Pak Budi sebelumnya (kalau ada).

---

## 📝 Step 8 — Lihat Daftar Acara (Publik)

Sekarang acara sudah published. Siapapun bisa melihatnya.

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/events` |

**Tidak perlu token** — ini endpoint publik.

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Daftar acara berhasil diambil.",
  "data": [
    {
      "id": "1",
      "title": "Resepsi Pernikahan Anak Pak Budi",
      "status": "published",
      "startDatetime": "2026-06-15T08:00:00.000Z",
      "locationName": "Gedung Serbaguna Yogyakarta",
      "eventCategory": { "name": "Pernikahan" },
      "user": { "name": "Pak Budi Santoso" },
      "_count": { "eventGuests": 0 }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1
  }
}
```

### Dengan Filter (opsional):

Kamu bisa tambahkan query parameter:

```
{{base_url}}/events?page=1&limit=5&categoryId=3&search=pernikahan
```

---

## 📝 Step 9 — Lihat Detail Acara

Lihat detail lengkap satu acara.

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/events/{{event_id}}` |

**Tidak perlu token.**

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Detail acara berhasil diambil.",
  "data": {
    "id": "1",
    "title": "Resepsi Pernikahan Anak Pak Budi",
    "description": "Menikahkan putra pertama kami...",
    "status": "published",
    "locationName": "Gedung Serbaguna Yogyakarta",
    "locationAddress": "Jl. Solo Km 5, ...",
    "locationLat": -7.7956,
    "locationLng": 110.3695,
    "startDatetime": "2026-06-15T08:00:00.000Z",
    "endDatetime": "2026-06-15T15:00:00.000Z",
    "maxGuests": 50,
    "eventCategory": {
      "id": 3,
      "name": "Pernikahan"
    },
    "user": {
      "id": "1",
      "name": "Pak Budi Santoso"
    },
    "giftRecommendations": [],
    "_count": {
      "eventGuests": 0
    }
  }
}
```

---

## 📝 Step 10 — Login User B

Sekarang ganti perspektif ke Ibu Sari. Login dulu.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/auth/login` |

### Body (JSON):

```json
{
  "email": "sari@email.com",
  "password": "password123"
}
```

**Update `token_b`** dengan token dari response.

---

## 📝 Step 11 — User B Daftar Jadi Tamu

Ibu Sari ingin hadir dan membawa **beras 5 kg** dan **uang Rp 50.000**.

| Setting | Value |
|---------|-------|
| **Method** | `POST` |
| **URL** | `{{base_url}}/events/{{event_id}}/guests` |
| **Authorization** | `Bearer {{token_b}}` |

### Body (JSON):

```json
{
  "notesFromGuest": "Semoga acaranya lancar ya Pak Budi. Saya ingin ikut meramaikan.",
  "gifts": [
    {
      "giftCategoryId": 1,
      "quantity": 5,
      "notes": "Beras premium cap Jago"
    },
    {
      "giftCategoryId": 10,
      "quantity": 50000
    }
  ]
}
```

> ⚠️ Sesuaikan `giftCategoryId`:
> - `1` = Beras (cek dari Step 5b)
> - `10` = Uang (cek dari Step 5b)
> - `quantity` untuk Uang dalam nominal Rupiah

### ✅ Expected Response (201):

```json
{
  "success": true,
  "message": "Pengajuan berhasil dikirim.",
  "data": {
    "id": "1",
    "eventId": "1",
    "userId": "2",
    "applicationStatus": "pending",
    "attendanceStatus": "not_verified",
    "giftVerified": false,
    "notesFromGuest": "Semoga acaranya lancar ya Pak Budi...",
    "guestGifts": [
      {
        "id": "1",
        "giftCategory": { "name": "Beras", "unit": "kg" },
        "quantity": 5
      },
      {
        "id": "2",
        "giftCategory": { "name": "Uang", "unit": "Rp" },
        "quantity": 50000
      }
    ],
    "user": {
      "id": "2",
      "name": "Ibu Sari Wulandari"
    }
  }
}
```

> 📌 **Simpan `id`** (id pengajuan tamu) ke variable `guest_id`.
>
> Post-response script:
> ```javascript
> const res = pm.response.json();
> if (res.data && res.data.id) {
>     pm.collectionVariables.set("guest_id", res.data.id);
> }
> ```

> 🔔 **Di balik layar:** Pak Budi (User A) otomatis mendapat notifikasi bertipe `new_applicant`.

---

## 📝 Step 12 — User A Lihat Daftar Tamu

Pak Budi login kembali untuk melihat siapa saja yang mendaftar.

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/events/{{event_id}}/guests` |
| **Authorization** | `Bearer {{token_a}}` |

> ⚠️ **Hanya pemilik acara** yang bisa melihat daftar tamu (BR-07).

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Daftar tamu berhasil diambil.",
  "data": [
    {
      "id": "1",
      "applicationStatus": "pending",
      "attendanceStatus": "not_verified",
      "giftVerified": false,
      "notesFromGuest": "Semoga acaranya lancar ya Pak Budi...",
      "user": {
        "id": "2",
        "name": "Ibu Sari Wulandari",
        "email": "sari@email.com",
        "phoneNumber": "081234567891"
      },
      "guestGifts": [
        {
          "giftCategory": { "name": "Beras", "unit": "kg" },
          "quantity": 5
        },
        {
          "giftCategory": { "name": "Uang", "unit": "Rp" },
          "quantity": 50000
        }
      ]
    }
  ]
}
```

---

## 📝 Step 13 — User A Terima Pengajuan Tamu

Pak Budi menerima pengajuan Ibu Sari.

| Setting | Value |
|---------|-------|
| **Method** | `PATCH` |
| **URL** | `{{base_url}}/events/{{event_id}}/guests/{{guest_id}}/status` |
| **Authorization** | `Bearer {{token_a}}` |

### Body — Terima:

```json
{
  "applicationStatus": "accepted"
}
```

### ✅ Expected Response (200):

```json
{
  "success": true,
  "message": "Status pengajuan berhasil diperbarui.",
  "data": {
    "id": "1",
    "applicationStatus": "accepted",
    "respondedAt": "2026-04-26T...",
    "user": {
      "name": "Ibu Sari Wulandari"
    }
  }
}
```

> 🔔 **Di balik layar:** Ibu Sari mendapat notifikasi bertipe `application_accepted`.

### Alternatif — Tolak Pengajuan:

```json
{
  "applicationStatus": "rejected",
  "rejectionReason": "Maaf, kuota tamu sudah penuh."
}
```

Response akan sama, tapi `applicationStatus` = `"rejected"`.

---

## 📝 Step 14 — Cek Notifikasi

### 14a. Notifikasi Pak Budi (User A)

| Setting | Value |
|---------|-------|
| **Method** | `GET` |
| **URL** | `{{base_url}}/notifications` |
| **Authorization** | `Bearer {{token_a}}` |

### ✅ Expected Response:

```json
{
  "data": {
    "notifications": [
      {
        "id": "1",
        "type": "new_applicant",
        "title": "Pengajuan Tamu Baru 📩",
        "message": "Ada tamu baru yang mengajukan diri untuk acara \"Resepsi Pernikahan Anak Pak Budi\".",
        "isRead": false,
        "sender": { "name": "Ibu Sari Wulandari" },
        "relatedEvent": { "title": "Resepsi Pernikahan Anak Pak Budi" }
      }
    ],
    "unreadCount": 1
  }
}
```

### 14b. Notifikasi Ibu Sari (User B)

Ganti Authorization ke `Bearer {{token_b}}`:

```json
{
  "data": {
    "notifications": [
      {
        "type": "application_accepted",
        "title": "Pengajuan Diterima ✅",
        "message": "Pengajuan kamu ke acara \"Resepsi Pernikahan Anak Pak Budi\" telah diterima!",
        "isRead": false
      }
    ],
    "unreadCount": 1
  }
}
```

---

## 🎁 Bonus: Skenario Tolak & Error

Berikut beberapa skenario error yang bisa kamu coba untuk membuktikan bahwa business rules berjalan dengan benar.

### ❌ User tidak bisa daftar ke acara miliknya sendiri (BR-02)

```
POST {{base_url}}/events/{{event_id}}/guests
Authorization: Bearer {{token_a}}       ← token pemilik acara
```

```json
{
  "gifts": [{ "giftCategoryId": 1, "quantity": 3 }]
}
```

**Expected:** `400` — `"Tidak bisa mendaftar ke acara milik sendiri."`

---

### ❌ User tidak bisa daftar dua kali (BR-03)

Coba ulangi Step 11 dengan User B yang sama.

**Expected:** `409` — `"Data dengan ... tersebut sudah ada."`

---

### ❌ Daftar tanpa bawaan (BR-04)

```json
{
  "gifts": []
}
```

**Expected:** `400` — `"Minimal harus ada 1 bawaan"`

---

### ❌ Edit bawaan setelah diterima (BR-05)

Setelah pengajuan di-accept (Step 13), coba tambah bawaan:

```
POST {{base_url}}/guests/{{guest_id}}/gifts
Authorization: Bearer {{token_b}}
```

```json
{
  "giftCategoryId": 2,
  "quantity": 3
}
```

**Expected:** `400` — `"Bawaan tidak bisa diubah setelah pengajuan diterima/ditolak."`

---

### ❌ Jadwal acara bertabrakan (BR-01)

Coba buat acara baru dengan waktu yang sama (sebagai User A):

```json
{
  "eventCategoryId": 2,
  "title": "Acara Bertabrakan",
  "locationName": "Tempat Lain",
  "locationAddress": "Alamat Lain",
  "startDatetime": "2026-06-15T10:00:00.000Z",
  "endDatetime": "2026-06-15T14:00:00.000Z"
}
```

**Expected:** `409` — `"Jadwal bertabrakan dengan acara ..."`

---

### ❌ Non-pemilik coba lihat daftar tamu (BR-07)

```
GET {{base_url}}/events/{{event_id}}/guests
Authorization: Bearer {{token_b}}       ← token tamu, bukan pemilik
```

**Expected:** `403` — `"Anda bukan pemilik acara ini."`

---

## 💡 Tips Postman

### 1. Gunakan Environment/Variables

Simpan token dan ID ke **Collection Variables** agar tidak perlu copy-paste manual setiap request.

### 2. Atur Folder

Organisasi request dalam folder:

```
📁 Buwoh API
  📁 Auth
    → Register User A
    → Register User B
    → Login User A
    → Login User B
    → Get Me
  📁 Master Data
    → Event Categories
    → Gift Categories
  📁 Events
    → Create Event
    → Publish Event
    → List Events (Public)
    → Detail Event
    → My Events
    → Delete Event
  📁 Guests
    → Apply as Guest
    → List Guests
    → Accept Guest
    → Reject Guest
  📁 Notifications
    → List Notifications
    → Mark as Read
```

### 3. Auto-Save Token dengan Post-Response Script

Di setiap request login/register, tambahkan script ini di tab **Scripts → Post-response**:

```javascript
const res = pm.response.json();
if (res.data && res.data.token) {
    // Ganti "token_a" sesuai user
    pm.collectionVariables.set("token_a", res.data.token);
    console.log("Token saved!");
}
```

### 4. Set Authorization di Level Collection

1. Klik Collection `Buwoh API`
2. Tab **Authorization**
3. Type: **Bearer Token**
4. Token: `{{token_a}}`

Semua request di Collection ini otomatis menggunakan token tersebut. Untuk request yang pakai `token_b`, override di level request.

### 5. Urutan Testing

Jalankan request **sesuai urutan** yang ada di dokumen ini (Step 1 → Step 14) karena setiap step bergantung pada step sebelumnya.

---

## 📊 Ringkasan Endpoint

| # | Method | Endpoint | Auth | Keterangan |
|---|--------|----------|------|------------|
| 1 | `POST` | `/auth/register` | ❌ | Registrasi user baru |
| 2 | `POST` | `/auth/login` | ❌ | Login, dapat token |
| 3 | `GET` | `/auth/me` | ✅ | Data user dari token |
| 4 | `GET` | `/event-categories` | ❌ | Daftar kategori acara |
| 5 | `GET` | `/gift-categories` | ❌ | Daftar kategori bawaan |
| 6 | `POST` | `/events` | ✅ | Buat acara baru (draft) |
| 7 | `PATCH` | `/events/:id/status` | ✅ | Ubah status (publish dll) |
| 8 | `GET` | `/events` | ❌ | List acara publik |
| 9 | `GET` | `/events/:id` | ❌ | Detail satu acara |
| 10 | `POST` | `/events/:id/guests` | ✅ | Daftar jadi tamu + bawaan |
| 11 | `GET` | `/events/:id/guests` | ✅ | List tamu (owner only) |
| 12 | `PATCH` | `/events/:id/guests/:gId/status` | ✅ | Terima/tolak tamu |
| 13 | `GET` | `/notifications` | ✅ | List notifikasi |

---

> 📝 **Catatan:** Semua endpoint menggunakan prefix `http://localhost:3000/api/v1`. Pastikan server sudah berjalan dengan `npm run dev` sebelum testing.

---

*Dokumen ini dibuat untuk membantu testing API Buwoh pada Postman. Selamat mencoba! 🚀*
