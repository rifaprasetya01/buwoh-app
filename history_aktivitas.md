# History Aktivitas BuwohApp

<!-- 
Format: 
[tanggal-bulan-tahun, jam:menit:detik]: {Keterangan aktivitas yang dilakukan} ({Kategori: backend\frontend\fullstack}) 
-->

[05-05-2026, 15:00:45]: Menonaktifkan transisi otomatis pada splash screen untuk persiapan re-design (frontend)
[05-05-2026, 15:07:30]: Menambahkan efek blur pada elemen dekorasi (GlowBlob) di splash screen (frontend)
[05-05-2026, 15:18:00]: Mengaktifkan kembali transisi otomatis pada splash screen setelah selesai re-design (frontend)
[05-05-2026, 15:25:00]: Modularisasi widget dekorasi (BuwohGlowBlob & BuwohDot) ke file terpisah agar dapat digunakan di halaman lain (frontend)
[05-05-2026, 15:37:00]: Modularisasi widget form (BuwohFieldLabel, BuwohInputField, BuwohPasswordField, BuwohPrimaryButton) ke file terpisah (frontend)
[05-05-2026, 15:40:00]: Reorganisasi struktur widgets: memisahkan setiap class menjadi file terpisah dalam folder (form/ & decoration/) dan membuat barrel file (widgets.dart) (frontend)
[05-05-2026, 15:47:00]: Menyelaraskan UI halaman Register agar identik dengan halaman Login, menambahkan field Nama Lengkap, dan memperbarui teks/navigasi (frontend)
[05-05-2026, 16:00:00]: Melakukan modularisasi besar-besaran komponen UI (cards, list_items, navigation) serta mengekstrak warna hardcoded ke AppColors (frontend)
[05-05-2026, 16:15:00]: Memperbaiki masalah IDE (seperti missing braces, pemakaian underscore ganda di callback) dan me-migrate penggunaan .withOpacity yang deprecated menjadi .withValues (frontend)
[05-05-2026, 16:20:00]: Membersihkan unused variables dan unused class (_BottomNav) di berbagai screen dengan memberikan komentar agar kode lebih bersih dari warning (frontend)
[05-05-2026, 16:45:00]: Memperbarui UI Bottom Navbar dengan menyamakan proporsi lebar dan tinggi tiap menu serta melakukan penyesuaian gaya tampilan saat aktif (frontend)

