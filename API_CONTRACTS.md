# API Contracts - Buwoh App

Dokumen ini berisi daftar kontrak API yang diperlukan untuk mendukung fitur-fitur pada aplikasi Buwoh berdasarkan analisis tampilan UI.

## 1. Authentication

### Login
Digunakan untuk masuk ke dalam aplikasi.
- **Endpoint**: `POST /api/auth/login`
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response (Success 200)**:
  ```json
  {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "name": "Budi",
      "email": "user@example.com"
    }
  }
  ```

### Register
Digunakan untuk mendaftarkan akun baru.
- **Endpoint**: `POST /api/auth/register`
- **Request Body**:
  ```json
  {
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "phone": "08123456789",
    "password": "password123"
  }
  ```
- **Response (Created 201)**:
  ```json
  {
    "message": "Registration successful",
    "user": {
      "id": 1,
      "name": "Budi Santoso"
    }
  }
  ```

---

## 2. User Profile & Dashboard

### Get User Profile
Mengambil data profil untuk header dashboard.
- **Endpoint**: `GET /api/user/profile`
- **Response (Success 200)**:
  ```json
  {
    "name": "Budi",
    "location": "Jakarta Selatan",
    "avatar_url": "https://i.pravatar.cc/150?img=3",
    "notifications_count": 2
  }
  ```

---

## 3. Event & Invitation Management

### Get Latest Invitations
Mengambil daftar undangan terbaru (untuk horizontal scroll di Beranda).
- **Endpoint**: `GET /api/events/latest`
- **Response (Success 200)**:
  ```json
  [
    {
      "id": 101,
      "name": "Areta & Fajar",
      "date": "Sabtu, 09.00",
      "type": "BUKA BUDI",
      "is_highlighted": true,
      "subtitle": null
    },
    {
      "id": 102,
      "name": "Putra Bpk. Slamet",
      "date": "15 SEP",
      "type": "KHITANAN",
      "is_highlighted": false,
      "subtitle": "Gedung Serbaguna Hl"
    }
  ]
  ```

### Get Upcoming Agenda
Mengambil daftar agenda mendatang (untuk list vertikal di Beranda).
- **Endpoint**: `GET /api/events/upcoming`
- **Response (Success 200)**:
  ```json
  [
    {
      "id": 201,
      "title": "Pernikahan Dimas & Ratna",
      "host": "Bpk. Bambang Hermawan",
      "location": "Balai Sudirman, Tebet, Jakarta Selatan",
      "date_day": "12",
      "date_month": "OKT",
      "time": "19.00 - 21.00 WIB",
      "distance_km": "1.3km",
      "image_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600"
    }
  ]
  ```

### Create New Event
Mengirim data untuk membuat acara/hajatan baru.
- **Endpoint**: `POST /api/events`
- **Request Body**:
  ```json
  {
    "name": "Pernikahan Budi & Ani",
    "start_date": "2025-06-14T09:00:00Z",
    "end_date": "2025-06-14T14:00:00Z",
    "description": "Mohon doa restu untuk pernikahan kami.",
    "location": {
      "name": "Kediaman Bpk. Rudi, Jakarta",
      "latitude": -6.2088,
      "longitude": 106.8456
    },
    "contribution_preferences": {
      "beras": true,
      "gula": false,
      "uang": true
    }
  }
  ```
- **Response (Created 201)**:
  ```json
  {
    "id": 301,
    "message": "Event created successfully",
    "share_url": "https://buwoh.app/invite/301"
  }
  ```

---

## 4. Invitation Detail

### Get Event Detail
Mengambil detail lengkap sebuah undangan.
- **Endpoint**: `GET /api/events/{id}`
- **Response (Success 200)**:
  ```json
  {
    "id": 201,
    "nama_acara": "Pernikahan Dimas & Ratna",
    "nama_host": "Bpk. Bambang Hermawan",
    "tanggal": "Sabtu, 12 Okt 2024",
    "waktu": "19.00 - 21.00 WIB",
    "lokasi": "Balai Sudirman, Tebet, Jakarta Selatan",
    "jenis": "PERNIKAHAN",
    "subtitle": "Hajatan Keluarga Besar Bpk. Bambang Hermawan",
    "is_prioritas": true,
    "jarak_km": "1.3km",
    "image_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600"
  }
  ```

---

## 5. History (Riwayat)

### Get History List
Mengambil daftar riwayat kontribusi/buwoh user.
- **Endpoint**: `GET /api/history`
- **Query Parameters**:
  - `tag`: Filter berdasarkan tag (contoh: `Uang`, `Beras`, `Gula`). Opsional.
  - `search`: Pencarian berdasarkan nama acara atau tuan rumah. Opsional.
- **Response (Success 200)**:
  ```json
  [
    {
      "id": 401,
      "jenis": "Balas Budi",
      "is_balas_budi": true,
      "tanggal": "12 Okt 2023",
      "nama": "Nikahan Budi & Susi",
      "host": "Keluarga Bapak Ahmad",
      "kontribusi": [
        {
          "type": "uang",
          "label": "Rp 500.000"
        },
        {
          "type": "beras",
          "label": "5 kg"
        }
      ],
      "status": "diterima",
      "tags": ["Uang", "Beras"]
    },
    {
      "id": 402,
      "jenis": "Walimatul Ursy",
      "is_balas_budi": false,
      "tanggal": "Baru Saja",
      "nama": "Pernikahan Dian & Ari",
      "host": "Bapak Haji Sulaiman",
      "kontribusi": [
        {
          "type": "uang",
          "label": "Rp 1.000.000"
        }
      ],
      "status": "menunggu",
      "tags": ["Uang"]
    }
  ]
  ```

### Get History Detail
Mengambil detail lengkap dari satu item riwayat.
- **Endpoint**: `GET /api/history/{id}`
- **Response (Success 200)**:
  ```json
  {
    "id": 401,
    "jenis": "Balas Budi",
    "is_balas_budi": true,
    "tanggal_lengkap": "Kamis, 12 Oktober 2023",
    "nama_acara": "Nikahan Budi & Susi",
    "nama_host": "Keluarga Bapak Ahmad",
    "lokasi": "Gedung Serbaguna, Jakarta",
    "kontribusi": [
      {
        "type": "uang",
        "label": "Rp 500.000"
      },
      {
        "type": "beras",
        "label": "5 kg"
      }
    ],
    "status": "diterima",
    "catatan": "Terima kasih atas kehadirannya."
  }
  ```
