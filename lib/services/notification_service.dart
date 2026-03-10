import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // ป้องกันแจ้งเตือนซ้ำถี่เกินไป
  static DateTime? _lastGasNotification;
  static DateTime? _lastTempNotification;
  static const _cooldown = Duration(minutes: 1);

  // ค่า threshold
  static const double gasWarningPPM = 1500;
  static const double gasDangerPPM = 3000;
  static const double tempHighC = 40;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // ขอ permission สำหรับ Android 13+
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    debugPrint('🔔 Notification permission granted: $granted');

    _isInitialized = true;
  }

  static Future<void> checkAndNotify({
    required double gasPPM,
    required double temperature,
  }) async {
    if (!_isInitialized) {
      debugPrint('🔔 NotificationService not initialized!');
      return;
    }

    final now = DateTime.now();
    debugPrint('🔔 checkAndNotify: gas=$gasPPM, temp=$temperature');

    // ตรวจค่าแก๊ส
    if (gasPPM >= gasDangerPPM) {
      if (_lastGasNotification == null ||
          now.difference(_lastGasNotification!) > _cooldown) {
        await _showNotification(
          id: 1,
          title: '⚠️ แก๊สรั่วไหลระดับอันตราย!',
          body: 'ค่า MQ2: ${gasPPM.toStringAsFixed(0)} PPM (เกิน $gasDangerPPM)',
          channelId: 'gas_danger',
          channelName: 'แจ้งเตือนแก๊สอันตราย',
          importance: Importance.max,
          priority: Priority.max,
        );
        _lastGasNotification = now;
      }
    } else if (gasPPM >= gasWarningPPM) {
      if (_lastGasNotification == null ||
          now.difference(_lastGasNotification!) > _cooldown) {
        await _showNotification(
          id: 2,
          title: '⚡ แก๊สรั่วไหลระดับเตือน',
          body: 'ค่า MQ2: ${gasPPM.toStringAsFixed(0)} PPM (เกิน $gasWarningPPM)',
          channelId: 'gas_warning',
          channelName: 'แจ้งเตือนแก๊สระดับกลาง',
          importance: Importance.high,
          priority: Priority.high,
        );
        _lastGasNotification = now;
      }
    }

    // ตรวจอุณหภูมิ
    if (temperature >= tempHighC) {
      if (_lastTempNotification == null ||
          now.difference(_lastTempNotification!) > _cooldown) {
        await _showNotification(
          id: 3,
          title: '🌡️ อุณหภูมิสูงผิดปกติ!',
          body: 'อุณหภูมิ: ${temperature.toStringAsFixed(1)} °C (เกิน $tempHighC°C)',
          channelId: 'temp_warning',
          channelName: 'แจ้งเตือนอุณหภูมิ',
          importance: Importance.high,
          priority: Priority.high,
        );
        _lastTempNotification = now;
      }
    }
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required Importance importance,
    required Priority priority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      enableLights: true,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
    );

    debugPrint('🔔 Showing notification: $title');

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
