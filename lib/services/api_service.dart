import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.45.255.210:8000/api';

  /// ================= AUTH =================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return jsonDecode(res.body);
  }

  /// ================= PROFILE =================

  /// GET PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(res.body);
  }

  /// UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {'Accept': 'application/json'},
      body: data,
    );

    return jsonDecode(res.body);
  }

  /// DELETE ACCOUNT
  static Future<Map<String, dynamic>> deleteAccount() async {
    final res = await http.delete(
      Uri.parse('$baseUrl/profile'),
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(res.body);
  }

  /// ================= PRODUCTS =================

  static Future<List<dynamic>> getProducts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Server error ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('getProducts error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getProduct(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Accept': 'application/json'},
      body: data,
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProduct(
      int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Accept': 'application/json'},
      body: data,
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(res.body);
  }
}
