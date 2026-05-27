# BuwohApp API Contract

This document outlines the REST API contract required to support the BuwohApp frontend mobile application. It is derived from a comprehensive analysis of the existing Flutter UI, state management, and user flows.

## Base URL
`/api/v1`

---

## 1. Authentication

### 1.1 Login
Authenticate a user and return an access token.
- **Endpoint:** `POST /auth/login`
- **Request Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "securepassword123"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5c...",
    "user": {
      "id": "usr_123",
      "name": "Ahmad Sudiro",
      "email": "user@example.com",
      "photoUrl": "https://..."
    }
  }
  ```

### 1.2 Register
Create a new user account.
- **Endpoint:** `POST /auth/register`
- **Request Body:**
  ```json
  {
    "name": "Ahmad Sudiro",
    "email": "user@example.com",
    "password": "securepassword123",
    "confirmPassword": "securepassword123"
  }
  ```
- **Response (201 Created):**
  ```json
  {
    "message": "Registration successful",
    "user": {
      "id": "usr_123",
      "name": "Ahmad Sudiro",
      "email": "user@example.com"
    }
  }
  ```

### 1.3 Logout
Invalidate the current session token.
- **Endpoint:** `POST /auth/logout`
- **Headers:** `Authorization: Bearer <token>`
- **Response (200 OK):**
  ```json
  { "message": "Logged out successfully" }
  ```

---

## 2. User Profile

### 2.1 Get Profile
Fetch the current user's profile and summary statistics.
- **Endpoint:** `GET /user/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Response (200 OK):**
  ```json
  {
    "id": "usr_123",
    "name": "Ahmad Sudiro",
    "address": {
      "id": "addr_001",
      "street": "Jl. Melati No. 45",
      "rtRw": "001/002",
      "village": "Condongcatur",
      "district": "Depok",
      "city": "Kabupaten Sleman",
      "province": "DI Yogyakarta",
      "postalCode": "55283",
      "latitude": -7.759323,
      "longitude": 110.398453
    },
    "birthDate": "1995-08-12",
    "photoUrl": "https://...",
    "stats": {
      "totalBuwoh": 15,
      "totalEventsHosted": 3
    }
  }
  ```

### 2.2 Update Profile
Update user profile information, including profile picture and detailed address.
- **Endpoint:** `PUT /user/profile`
- **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
- **Request Body (Multipart):**
  - `name`: string
  - `birthDate`: YYYY-MM-DD
  - `address.street`: string
  - `address.rtRw`: string
  - `address.village`: string
  - `address.district`: string
  - `address.city`: string
  - `address.province`: string
  - `address.postalCode`: string
  - `address.latitude`: double
  - `address.longitude`: double
  - `photo`: file (optional)
- **Response (200 OK):**
  ```json
  {
    "message": "Profile updated successfully",
    "user": { ... }
  }
  ```

---

## 3. Events Management (Host View)

### 3.1 List Hosted Events
Retrieve events created by the user (Dashboard/Acara Saya).
- **Endpoint:** `GET /events`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:** `status=active|completed`
- **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "id": "evt_1",
        "title": "Aqiqah Anak Budi",
        "type": "Aqiqah",
        "locationName": "Balai Kartini, Jakarta",
        "date": "2024-10-24",
        "startTime": "09:00",
        "endTime": "14:00",
        "imageUrl": "https://...",
        "status": "active",
        "isPriority": true,
        "guestsAttended": 124,
        "guestsTotal": 200,
        "progressPercentage": 62
      }
    ]
  }
  ```

### 3.2 Create Event
Create a new event/hajatan. Host can specify the expected buwoh items (harapan buwohan).
- **Endpoint:** `POST /events`
- **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
- **Request Body (Multipart):**
  - `title`: string
  - `type`: string (e.g., Pernikahan, Khitanan)
  - `date`: YYYY-MM-DD
  - `startTime`: HH:mm (optional)
  - `endTime`: HH:mm (optional)
  - `locationName`: string
  - `mapLink`: string
  - `description`: string
  - `expectedContributions`: array of strings (e.g., `["uang", "beras"]`)
  - `coverImage`: file
- **Response (201 Created):**
  ```json
  {
    "message": "Event created successfully",
    "event": { "id": "evt_2", "title": "...", ... }
  }
  ```

### 3.3 Event Recap (Completed Event Summary)
Get the summary and guest list of a completed event.
- **Endpoint:** `GET /events/{eventId}/recap`
- **Headers:** `Authorization: Bearer <token>`
- **Response (200 OK):**
  ```json
  {
    "eventId": "evt_1",
    "title": "Khitanan Arkan",
    "date": "2023-10-12",
    "totalGuests": 150,
    "summary": {
      "uangTunai": 8200000,
      "berasKg": 125,
      "gulaKg": 45
    },
    "guests": [
      {
        "guestId": "usr_456",
        "name": "Budi Santoso",
        "avatarUrl": "https://...",
        "status": "attended",
        "contributions": [
          { "type": "uang", "value": "Rp 150.000" },
          { "type": "beras", "value": "5kg" }
        ]
      }
    ]
  }
  ```

---

## 4. Guest Management (Host View)

### 4.1 List Event Guests
List guests for an active event to validate their buwoh or mark attendance.
- **Endpoint:** `GET /events/{eventId}/guests`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:** `status=pending|validated|attended|absent`
- **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "guestId": "usr_789",
        "name": "Siti Aminah",
        "status": "pending",
        "timeArrived": "10:30 WIB",
        "contributions": [
          { "type": "uang", "value": "Rp 100.000" }
        ]
      }
    ]
  }
  ```

### 4.2 Update Guest Status (Validate/Attend)
Update the guest's status (e.g., validating their buwoh, or marking whether they actually attended the event).
- **Endpoint:** `PATCH /events/{eventId}/guests/{guestId}/status`
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "status": "attended" 
    // allowed values: "validated", "rejected", "attended", "absent"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "message": "Guest status updated to attended"
  }
  ```

---

## 5. Invitations (Guest View)

### 5.1 List Invitations
Get public or targeted invitations to attend.
- **Endpoint:** `GET /invitations`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:** `search=...`, `type=Pernikahan|Khitanan|Tasyakuran`
- **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "eventId": "evt_9",
        "type": "Pernikahan",
        "title": "Pernikahan Anisa & Bayu",
        "hostName": "Bpk. Haji Sulaiman",
        "date": "2024-10-24",
        "time": "09.00 - 21.00 WIB",
        "locationName": "Griya Ageng, Solo",
        "distanceKm": 2.4,
        "imageUrl": "https://...",
        "isBalasBudi": true
      }
    ]
  }
  ```

### 5.2 Get Invitation Details
- **Endpoint:** `GET /invitations/{eventId}`
- **Headers:** `Authorization: Bearer <token>`
- **Response (200 OK):**
  ```json
  {
    "eventId": "evt_9",
    "title": "Pernikahan Anisa & Bayu",
    "description": "Assalamu'alaikum...",
    "expectedContributions": ["uang", "beras", "gula"],
    ...
  }
  ```

### 5.3 Submit Buwoh
Submit an intention to give buwoh at an event.
- **Endpoint:** `POST /invitations/{eventId}/buwoh`
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "contributions": [
      "uang",
      "beras"
    ]
  }
  ```
- **Response (201 Created):**
  ```json
  {
    "message": "Buwoh intention submitted successfully. Waiting for host validation."
  }
  ```

---

## 6. History (User Contributions)

### 6.1 Get Contribution History
List events the user has attended and contributed to.
- **Endpoint:** `GET /history`
- **Headers:** `Authorization: Bearer <token>`
- **Query Params:** `filter=Semua|Pernikahan|Khitanan...`
- **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "historyId": "hist_1",
        "eventId": "evt_10",
        "title": "Pernikahan Dinda & Reza",
        "hostName": "Keluarga Bpk. Santoso",
        "date": "2023-08-15",
        "locationName": "Gedung Wanita, Semarang",
        "type": "Pernikahan",
        "status": "attended",
        "contributions": [
          { "type": "uang", "value": "Rp 500.000" }
        ]
      }
    ]
  }
  ```

### 6.2 Get History Details
- **Endpoint:** `GET /history/{historyId}`
- **Headers:** `Authorization: Bearer <token>`
- **Response (200 OK):**
  Detailed response similar to the list item, including full event context and specific contribution items.
