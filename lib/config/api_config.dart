class ApiConfig {
  // Pour Android Emulator
  static const String baseUrl = 'http://192.168.10.55:5000/api';
  
  // Pour iOS Simulator (utiliser localhost)
  // Pour appareil physique (utiliser votre IP locale)
  // static const String baseUrl = 'http://192.168.1.X:5000/api';
  
  static Map<String, String> getHeaders(String? token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
