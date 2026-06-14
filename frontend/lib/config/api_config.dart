class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:5000/api/v1'; // Menggunakan ADB reverse
  // static const String baseUrl = 'http://192.168.18.31:5000/api/v1'; 
  // Gunakan IP ini jika test di HP fisik tanpa kabel USB


  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
