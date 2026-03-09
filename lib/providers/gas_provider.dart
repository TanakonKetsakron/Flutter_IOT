import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GasProvider extends ChangeNotifier {
  final DatabaseReference _airDataRef =
      FirebaseDatabase.instance.ref("air_data");
  final DatabaseReference _deviceRef =
      FirebaseDatabase.instance.ref("device");
  final DatabaseReference _controlRef =
      FirebaseDatabase.instance.ref("control");
  final DatabaseReference _historyRef =
      FirebaseDatabase.instance.ref("air_history");

  StreamSubscription? _airDataSub;
  StreamSubscription? _deviceSub;
  StreamSubscription? _historySub;

  // ข้อมูล sensor (จาก /air_data)
  double temperature = 0;
  double humidity = 0;
  double gasPPM = 0;
  bool isConnected = false;

  // สถานะจาก ESP32 (จาก /device)
  bool buzzerActive = false;   // ESP32 เขียน /device/alert เมื่อ gas > 3000
  bool muteEnabled = false;    // Flutter เขียน /device/mute → ESP32 อ่าน

  // ข้อมูลย้อนหลัง
  List<Map<String, dynamic>> historyData = [];

  // สถานะ
  bool isLoading = true;

  GasProvider() {
    _listenAirData();
    _listenDevice();
    _listenHistory();
  }

  void _listenAirData() {
    _airDataSub = _airDataRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final map = data as Map;
      temperature = (map["temp"] ?? 0).toDouble();
      humidity = (map["hum"] ?? 0).toDouble();
      gasPPM = (map["gas"] ?? 0).toDouble();
      isConnected = true;
      isLoading = false;
      notifyListeners();
    }, onError: (_) {
      isConnected = false;
      isLoading = false;
      notifyListeners();
    });
  }

  // ฟัง /device — ESP32 เขียน alert, last_seen / Flutter เขียน mute
  void _listenDevice() {
    _deviceSub = _deviceRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final map = data as Map;
      buzzerActive = map["alert"] ?? false;  // ESP32 เขียนเมื่อ gas > 3000
      muteEnabled = map["mute"] ?? false;    // Flutter เขียน, ESP32 อ่าน
      notifyListeners();
    });
  }

  void _listenHistory() {
    _historySub =
        _historyRef.limitToLast(24).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final map = data as Map;
      historyData = map.entries.map((e) {
        final v = e.value as Map;
        return {
          "gas": (v["gas"] ?? 0).toDouble(),
          "temp": (v["temp"] ?? 0).toDouble(),
          "hum": (v["hum"] ?? 0).toDouble(),
        };
      }).toList();
      notifyListeners();
    });
  }

  // เปิด/ปิดเสียงเตือน → เขียนไป /device/mute (ESP32 อ่านจากที่นี่)
  Future<void> toggleMute(bool mute) async {
    // เขียน mute + alert พร้อมกัน
    // ถ้า mute → บังคับ alert = false เพื่อให้ ESP32 หยุด buzzer ทันที
    if (mute) {
      await _deviceRef.update({"mute": true, "alert": false});
    } else {
      await _deviceRef.update({"mute": false});
    }
  }

  // บังคับหยุด buzzer ทันที (เขียน mute=true + alert=false)
  Future<void> forceStopBuzzer() async {
    await _deviceRef.update({"mute": true, "alert": false});
  }

  // สถานะ gas level (สำหรับแสดง UI)
  String get gasStatus {
    if (gasPPM < 1500) return 'ปกติ';
    if (gasPPM < 3000) return 'ระดับกลาง';
    return 'ระดับสูง';
  }

  Color get gasStatusColor {
    if (gasPPM < 1500) return const Color(0xFF4CAF50);
    if (gasPPM < 3000) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String get gasStatusIcon {
    if (gasPPM < 1500) return '✅';
    if (gasPPM < 3000) return '⚡';
    return '⚠️';
  }

  // รีเซ็ท Sensor → เขียนไป /control/reset (ESP32 อ่านจากที่นี่)
  Future<void> resetSensor() async {
    await _controlRef.update({"reset": true});
  }

  @override
  void dispose() {
    _airDataSub?.cancel();
    _deviceSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
