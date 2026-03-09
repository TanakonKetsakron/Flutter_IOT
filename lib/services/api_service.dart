// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/gas_data.dart';

class ApiService {
  // 🔧 แก้ไข BASE_URL ให้ตรงกับเบสข้อมูลของคุณ
  static const String baseUrl = 'http://your-api-url.com/api';
  
  // ดึงค่าแก๊สและอุณหภูมิ-ความชื้น ล่าสุด (MQ2 + DHT11)
  static Future<GasData> getLatestData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gas-data/latest'),
        // Response: {timestamp, temperature(DHT11), humidity(DHT11), gasPPM(MQ2), gasMaxPPM(MQ2), connectionStatus}
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return GasData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('ล้มเหลว: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('เชื่อมต่อ API ไม่ได้: $e');
    }
  }

  // ดึงค่าแก๊สย้อนหลัง (24 ชั่วโมง)
  static Future<List<GasData>> getHistoricalData({
    int hours = 24,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gas-data/history?hours=$hours'),
        // Response: Array of GasData objects
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => GasData.fromJson(item)).toList();
      } else {
        throw Exception('ล้มเหลว: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ดึงข้อมูลย้อนหลังไม่ได้: $e');
    }
  }

  // เปิด/ปิด Alert Alarm
  static Future<bool> toggleAlert(bool enabled) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/device/alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enabled': enabled}),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('ควบคุม Alert ไม่ได้: $e');
    }
  }

  // รีเซ็ท MQ2 Sensor
  static Future<bool> resetSensor() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sensor/reset'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('รีเซ็ท Sensor ไม่ได้: $e');
    }
  }

  // Mock Data (สำหรับ development/testing)
  static GasData getMockData() {
    return GasData(
      timestamp: DateTime.now(),
      temperature: 28.5,           // จาก DHT11
      humidity: 55.0,              // จาก DHT11
      gasPPM: 342.0,               // ค่าแก๊สปัจจุบันจาก MQ2
      gasMaxPPM: 389.0,            // ค่าแก๊สสูงสุดจาก MQ2
      connectionStatus: 'connected',
    );
  }

  static List<GasData> getMockHistoricalData() {
    List<GasData> data = [];
    for (int i = 24; i > 0; i--) {
      data.add(GasData(
        timestamp: DateTime.now().subtract(Duration(hours: i)),
        temperature: 25.0 + (i % 10).toDouble(),  // DHT11
        humidity: 50.0 + (i % 15).toDouble(),     // DHT11
        gasPPM: 200.0 + (i * 3.5),                // MQ2
        gasMaxPPM: 400.0 + (i * 2),               // MQ2
        connectionStatus: 'connected',
      ));
    }
    return data;
  }
}
