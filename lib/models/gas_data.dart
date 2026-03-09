// lib/models/gas_data.dart

class GasData {
  final DateTime timestamp;
  final double temperature;        // จาก DHT11 (°C)
  final double humidity;           // จาก DHT11 (%)
  final double gasPPM;             // จาก MQ2 (ppm) - ค่าปัจจุบัน
  final double gasMaxPPM;          // จาก MQ2 (ppm) - ค่าสูงสุด
  final String connectionStatus;   // "connected" or "disconnected"

  GasData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.gasPPM,
    required this.gasMaxPPM,
    required this.connectionStatus,
  });

  factory GasData.fromJson(Map<String, dynamic> json) {
    return GasData(
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      gasPPM: (json['gasPPM'] ?? 0.0).toDouble(),
      gasMaxPPM: (json['gasMaxPPM'] ?? 0.0).toDouble(),
      connectionStatus: json['connectionStatus'] ?? 'disconnected',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'gasPPM': gasPPM,
      'gasMaxPPM': gasMaxPPM,
      'connectionStatus': connectionStatus,
    };
  }
}

class DeviceControl {
  final bool speakerEnabled;
  final bool systemActive;

  DeviceControl({
    required this.speakerEnabled,
    required this.systemActive,
  });

  factory DeviceControl.fromJson(Map<String, dynamic> json) {
    return DeviceControl(
      speakerEnabled: json['speakerEnabled'] ?? false,
      systemActive: json['systemActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speakerEnabled': speakerEnabled,
      'systemActive': systemActive,
    };
  }
}
