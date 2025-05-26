import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  final String baseUrl = 'http://10.0.2.2/bantoo_api'; // Sesuaikan dengan alamat API Anda

  // Ambil semua event
  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/read_events.php'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (responseData['status'] == 'success') {
        List<dynamic> eventsJson = responseData['data'];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to load events');
    }
  }
  
  // Ambil detail event berdasarkan ID
  Future<Event> getEventById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/get_event.php?id=$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (responseData['status'] == 'success') {
        return Event.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to load event details');
    }
  }
  
  // Buat event baru
  Future<Map<String, dynamic>> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_event.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(event.toJson()),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create event');
    }
  }
  
  // Update event
  Future<Map<String, dynamic>> updateEvent(Event event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_event.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(event.toJson()),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update event');
    }
  }
  
  // Hapus event
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_event.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete event');
    }
  }
}