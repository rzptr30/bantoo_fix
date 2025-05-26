import 'dart:async'; // Import ini diperlukan untuk TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donasi_ini.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this dependency

class ApiService {
  // Default server URL
  static String baseUrl = 'http://192.168.1.50/bantoo_api';
  static const String DEFAULT_URL = 'http://192.168.1.50/bantoo_api';
  
  // Initialize with stored URL if available
  static Future<void> initializeBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      baseUrl = prefs.getString('api_base_url') ?? DEFAULT_URL;
      print('ApiService initialized with baseUrl: $baseUrl');
    } catch (e) {
      print('Error initializing ApiService: $e');
      baseUrl = DEFAULT_URL;
    }
  }
  
  // Method to update the base URL
  static Future<void> updateBaseUrl(String newUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', newUrl);
      baseUrl = newUrl;
      print('BaseUrl updated to: $baseUrl');
    } catch (e) {
      print('Error updating baseUrl: $e');
    }
  }
  
  // Test connection to server
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/ping.php');
      
      final response = await http.get(Uri.parse('$baseUrl/ping.php'))
          .timeout(const Duration(seconds: 10));
      
      print('Connection test - Status Code: ${response.statusCode}');
      print('Connection test - Response Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Helper method to try connecting to a specific server URL
  static Future<bool> tryConnectToServer(String serverUrl) async {
    try {
      print('Checking connectivity to: $serverUrl/ping.php');
      
      final response = await http.get(Uri.parse('$serverUrl/ping.php'))
        .timeout(const Duration(seconds: 5));
      
      print('Connectivity check to $serverUrl - Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Successfully connected to $serverUrl');
        return true;
      }
      return false;
    } catch (e) {
      print('Connection to $serverUrl failed: $e');
      return false;
    }
  }
  
  // Improved connectivity check with multiple server options
  static Future<bool> _checkServerConnectivity() async {
    // First try the configured server
    if (await tryConnectToServer(baseUrl)) {
      return true;
    }
    
    // If that fails, try alternative server addresses
    final alternativeUrls = [
      'http://10.0.2.2/bantoo_api',     // Android emulator localhost
      'http://localhost/bantoo_api',     // Direct localhost
      'http://127.0.0.1/bantoo_api',     // Direct IP localhost
    ];
    
    for (String url in alternativeUrls) {
      if (url != baseUrl) {  // Skip if already tried
        print('Trying alternative server: $url');
        if (await tryConnectToServer(url)) {
          // If successful, update the baseUrl
          await updateBaseUrl(url);
          return true;
        }
      }
    }
    
    return false;
  }
  
  // Tambahkan fungsi test direct API
  static Future<bool> testDirectApi() async {
    try {
      print('Testing direct API at: $baseUrl/create_test.php');
      final testData = {
        'test': 'data',
        'timestamp': DateTime.now().toString()
      };
      
      print('Sending test data: ${json.encode(testData)}');
      
      final directTestResponse = await http.post(
        Uri.parse('$baseUrl/create_test.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(testData),
      ).timeout(const Duration(seconds: 10));
      
      print('Direct API test - Status Code: ${directTestResponse.statusCode}');
      print('Direct API test - Response Body: ${directTestResponse.body}');
      
      return directTestResponse.statusCode == 200;
    } catch (e) {
      print('Direct API test failed: $e');
      return false;
    }
  }

  // Get semua donasi
  static Future<List<Donasi>> getDonasi() async {
    try {
      // First, validate the connection to the server
      bool isConnected = await _checkServerConnectivity();
      if (!isConnected) {
        print('getDonasi - No connection to server. Check network settings or server status.');
        return [];
      }
      
      print('getDonasi - Fetching data from: $baseUrl/read.php');
      
      final response = await http.get(Uri.parse('$baseUrl/read.php'))
          .timeout(const Duration(seconds: 15)); // Tambahkan timeout
      
      print('getDonasi - Status Code: ${response.statusCode}');
      print('getDonasi - Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Cek apakah response body kosong atau null
        if (response.body.isEmpty) {
          print('getDonasi - Response body kosong');
          return []; // Kembalikan list kosong jika response body kosong
        }
        
        // Cek apakah response body hanya berisi "null" atau respons kosong
        final bodyTrim = response.body.trim();
        if (bodyTrim == 'null' || bodyTrim == '[]' || bodyTrim == 'false' || bodyTrim == '""') {
          print('getDonasi - Response body: $bodyTrim');
          return []; // Kembalikan list kosong
        }
        
        try {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => Donasi.fromJson(item)).toList();
        } catch (e) {
          // Error parsing JSON, kembalikan list kosong
          print('getDonasi - Error parsing JSON: $e');
          return [];
        }
      } else {
        // Server mengembalikan status code error
        print('getDonasi - Failed to load donasi: ${response.statusCode}');
        return []; // Kembalikan list kosong daripada throw exception
      }
    } on TimeoutException catch (_) {
      print('getDonasi - Request timed out');
      return [];
    } catch (e) {
      // Tangkap semua error dan kembalikan list kosong
      print('getDonasi - Error fetching donasi: $e');
      return []; // Kembalikan list kosong daripada throw exception
    }
  }

  // Test database connection through API
  static Future<bool> testDatabaseConnection() async {
    try {
      print('Testing database connection through API');
      
      final response = await http.get(
        Uri.parse('$baseUrl/test_db_connection.php')
      ).timeout(const Duration(seconds: 10));
      
      print('DB Connection test - Status Code: ${response.statusCode}');
      print('DB Connection test - Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          // If database connection is successful, the PHP script should return {"connected": true}
          return data['connected'] == true;
        } catch (e) {
          print('Error parsing DB connection response: $e');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }

  // Modified tambahDonasi method with better error handling and connection validation
  static Future<bool> tambahDonasi({
    String? nama,
    String? title,
    String? description,
    double? targetAmount,
    double? collectedAmount,
    String? foto,
    String? imageUrl,
    double? target,
    double? current,
    double? nominal,
    String? pesan,
    double? progress,
    String? deadline,
    bool? isEmergency,
  }) async {
    try {
      // First, validate the connection to the server
      bool isConnected = await _checkServerConnectivity();
      if (!isConnected) {
        print('tambahDonasi - No connection to server. Check network settings or server status.');
        return false;
      }
      
      // Prepare payload
      final Map<String, dynamic> payload = {
        'nama': nama,
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'collected_amount': collectedAmount ?? 0.0,
        'foto': foto,
        'image_url': imageUrl ?? '',
        'target': target,
        'current': current,
        'nominal': nominal,
        'pesan': pesan,
        'progress': progress,
        'deadline': deadline,
        'is_emergency': isEmergency,
      };
      
      // Filter out null values
      payload.removeWhere((key, value) => value == null);
      
      // Log payload
      print('tambahDonasi - Sending payload: ${json.encode(payload)}');
      
      // Create a client with lower timeout for faster feedback
      final client = http.Client();
      
      try {
        // Try new endpoint with shorter timeout
        final String endpoint = '$baseUrl/create_campaign.php';
        print('tambahDonasi - Using new endpoint URL: $endpoint');
        
        try {
          final response = await client.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          ).timeout(const Duration(seconds: 15)); // Reduced timeout
          
          print('tambahDonasi - Response status code: ${response.statusCode}');
          print('tambahDonasi - Response body: ${response.body}');
          
          if (response.statusCode == 200) {
            try {
              if (response.body.isNotEmpty) {
                final responseData = json.decode(response.body);
                print('tambahDonasi - Parsed response: $responseData');
                
                if (responseData['success'] == true) {
                  print('tambahDonasi - Success: ${responseData['message']}');
                  return true;
                } else {
                  print('tambahDonasi - API returned error: ${responseData['message']}');
                  return false;
                }
              }
            } catch (e) {
              print('tambahDonasi - Error parsing response: $e');
            }
            return true; // Default return if no error
          } else {
            print('tambahDonasi - Failed with status code: ${response.statusCode}');
            return false;
          }
        } on TimeoutException catch (_) {
          print('tambahDonasi - New endpoint timed out, trying original endpoint...');
          
          // Try original endpoint with shorter timeout
          try {
            final originalEndpoint = '$baseUrl/create.php';
            print('tambahDonasi - Using original endpoint: $originalEndpoint');
            
            final response = await client.post(
              Uri.parse(originalEndpoint),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            ).timeout(const Duration(seconds: 15)); // Reduced timeout
            
            print('tambahDonasi - Original endpoint response status: ${response.statusCode}');
            print('tambahDonasi - Original endpoint response body: ${response.body}');
            
            return response.statusCode == 200;
          } catch (e) {
            print('tambahDonasi - All endpoints failed: $e');
            return false;
          }
        }
      } finally {
        client.close(); // Always close the client to free resources
      }
    } catch (e) {
      print('tambahDonasi - Error: $e');
      return false;
    }
  }

  // Method tambah donasi baru (alias untuk tambahDonasi)
  static Future<bool> addDonasi({
    String? nama,
    String? title,
    String? description,
    double? targetAmount,
    double? collectedAmount,
    String? foto,
    String? imageUrl,
    double? target,
    double? current,
    double? nominal,
    String? pesan,
    double? progress,
    String? deadline,
    bool? isEmergency,
  }) async {
    // Panggil tambahDonasi untuk menjaga konsistensi
    return tambahDonasi(
      nama: nama,
      title: title,
      description: description,
      targetAmount: targetAmount,
      collectedAmount: collectedAmount,
      foto: foto,
      imageUrl: imageUrl,
      target: target,
      current: current,
      nominal: nominal,
      pesan: pesan,
      progress: progress,
      deadline: deadline,
      isEmergency: isEmergency,
    );
  }

  // Update donasi dengan timeout dan logging
  static Future<bool> updateDonasi({
    required int id,
    String? nama,
    String? title,
    String? description,
    double? targetAmount,
    double? collectedAmount,
    String? foto,
    String? imageUrl,
    double? target,
    double? current,
    double? nominal,
    String? pesan,
    double? progress,
    String? deadline,
    bool? isEmergency,
  }) async {
    try {
      // First, validate the connection to the server
      bool isConnected = await _checkServerConnectivity();
      if (!isConnected) {
        print('updateDonasi - No connection to server. Check network settings or server status.');
        return false;
      }
      
      // Buat payload untuk dikirim ke server
      final Map<String, dynamic> payload = {
        'id': id,
        'nama': nama,
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'collected_amount': collectedAmount,
        'foto': foto,
        'image_url': imageUrl,
        'target': target,
        'current': current,
        'nominal': nominal,
        'pesan': pesan,
        'progress': progress,
        'deadline': deadline,
        'is_emergency': isEmergency,
      };
      
      // Filter out null values
      payload.removeWhere((key, value) => value == null);
      
      // Log payload yang akan dikirim
      print('updateDonasi - Sending payload: ${json.encode(payload)}');
      print('updateDonasi - Endpoint URL: $baseUrl/update.php');
      
      // Create a client with lower timeout
      final client = http.Client();
      
      try {
        // Kirim request ke server dengan timeout 15 detik
        final response = await client.post(
          Uri.parse('$baseUrl/update.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        ).timeout(const Duration(seconds: 15)); // Reduced timeout
        
        // Log response dari server
        print('updateDonasi - Response status code: ${response.statusCode}');
        print('updateDonasi - Response body: ${response.body}');
        
        // Parse response body jika ada
        Map<String, dynamic>? responseData;
        try {
          if (response.body.isNotEmpty) {
            responseData = json.decode(response.body);
            print('updateDonasi - Parsed response: $responseData');
          }
        } catch (e) {
          print('updateDonasi - Error parsing response: $e');
        }
        
        // Cek status code dan 'success' field dari response
        if (response.statusCode == 200) {
          if (responseData != null && responseData['success'] == true) {
            print('updateDonasi - Success: ${responseData['message']}');
            return true;
          } else if (responseData != null) {
            print('updateDonasi - Failed: ${responseData['message']}');
            return false;
          }
          return true; // Default success jika tidak ada field 'success' di response
        } else {
          print('updateDonasi - Failed with status code: ${response.statusCode}');
          return false;
        }
      } finally {
        client.close(); // Always close the client to free resources
      }
    } on TimeoutException catch (_) {
      print('updateDonasi - Request timed out after 15 seconds');
      return false;
    } catch (e) {
      print('updateDonasi - Error: $e');
      return false;
    }
  }

  // Delete donasi dengan timeout dan logging
  static Future<bool> deleteDonasi(int id) async {
    try {
      // First, validate the connection to the server
      bool isConnected = await _checkServerConnectivity();
      if (!isConnected) {
        print('deleteDonasi - No connection to server. Check network settings or server status.');
        return false;
      }
      
      // Log payload yang akan dikirim
      print('deleteDonasi - Deleting donasi with ID: $id');
      print('deleteDonasi - Endpoint URL: $baseUrl/delete.php');
      
      // Create a client with lower timeout
      final client = http.Client();
      
      try {
        // Kirim request ke server dengan timeout 15 detik
        final response = await client.post(
          Uri.parse('$baseUrl/delete.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id': id}),
        ).timeout(const Duration(seconds: 15)); // Reduced timeout
        
        // Log response dari server
        print('deleteDonasi - Response status code: ${response.statusCode}');
        print('deleteDonasi - Response body: ${response.body}');
        
        // Parse response body jika ada
        Map<String, dynamic>? responseData;
        try {
          if (response.body.isNotEmpty) {
            responseData = json.decode(response.body);
            print('deleteDonasi - Parsed response: $responseData');
          }
        } catch (e) {
          print('deleteDonasi - Error parsing response: $e');
        }
        
        return response.statusCode == 200;
      } finally {
        client.close(); // Always close the client to free resources
      }
    } on TimeoutException catch (_) {
      print('deleteDonasi - Request timed out after 15 seconds');
      return false;
    } catch (e) {
      print('deleteDonasi - Error: $e');
      return false;
    }
  }
  
  // Get donasi by id dengan timeout dan logging
  static Future<Donasi?> getDonasiById(int id) async {
    try {
      // First, validate the connection to the server
      bool isConnected = await _checkServerConnectivity();
      if (!isConnected) {
        print('getDonasiById - No connection to server. Check network settings or server status.');
        return null;
      }
      
      print('getDonasiById - Fetching donasi with ID: $id');
      print('getDonasiById - Endpoint URL: $baseUrl/read_single.php?id=$id');
      
      // Create a client with lower timeout
      final client = http.Client();
      
      try {
        final response = await client.get(
          Uri.parse('$baseUrl/read_single.php?id=$id'),
        ).timeout(const Duration(seconds: 15)); // Reduced timeout
        
        print('getDonasiById - Response status code: ${response.statusCode}');
        print('getDonasiById - Response body: ${response.body}');
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Donasi.fromJson(data);
        } else {
          print('getDonasiById - Failed to fetch donasi: ${response.statusCode}');
          return null;
        }
      } finally {
        client.close(); // Always close the client to free resources
      }
    } on TimeoutException catch (_) {
      print('getDonasiById - Request timed out after 15 seconds');
      return null;
    } catch (e) {
      print('getDonasiById - Error: $e');
      return null;
    }
  }
}