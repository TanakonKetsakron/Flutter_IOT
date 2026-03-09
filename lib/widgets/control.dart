import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gas_provider.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Consumer<GasProvider>(
              builder: (context, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'การควบคุม',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'จัดการการทำงานของเครื่อง',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gas Level Indicator
                    _buildGasLevelBanner(provider),
                    const SizedBox(height: 20),

                    // Force Stop Buzzer (เมื่อ buzzer ดังอยู่)
                    if (provider.buzzerActive || !provider.muteEnabled)
                      _buildForceStopButton(context, provider),
                    if (provider.buzzerActive || !provider.muteEnabled)
                      const SizedBox(height: 16),

                    // Alert (Mute) Toggle
                    _buildAlertButton(context, provider),
                    const SizedBox(height: 16),

                    // Reset Button
                    _buildResetButton(context, provider),
                    const SizedBox(height: 24),

                    // Status Info
                    _buildStatusBox(provider),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGasLevelBanner(GasProvider provider) {
    final isAlert = provider.buzzerActive;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert
            ? const Color(0xFFF44336).withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: isAlert
              ? const Color(0xFFF44336).withOpacity(0.6)
              : Colors.white.withOpacity(0.2),
          width: isAlert ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: provider.gasStatusColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                provider.gasStatusIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gas: ${provider.gasPPM.toStringAsFixed(0)} PPM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAlert
                      ? '🔔 Buzzer กำลังดัง! ${provider.muteEnabled ? "(Mute อยู่)" : ""}'
                      : '${provider.gasStatus} — ${provider.muteEnabled ? "Mute อยู่" : "แจ้งเตือนเปิด"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertButton(BuildContext context, GasProvider provider) {
    // mute = false → เสียงเตือนเปิด (แจ้งเตือนอัตโนมัติ), mute = true → ปิดเสียง
    final alertOn = !provider.muteEnabled;
    return GestureDetector(
      onTap: () {
        provider.toggleMute(!provider.muteEnabled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(alertOn
                ? '🔇 ปิดเสียงเตือนแล้ว (Mute)'
                : '🔊 เปิดเสียงเตือนแล้ว'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: alertOn ? const Color(0xFF4CAF50) : const Color(0xFF757575),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (alertOn ? const Color(0xFF4CAF50) : const Color(0xFF757575))
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                alertOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Alert Alarm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              alertOn ? 'เปิด (แจ้งเตือนอัตโนมัติ)' : 'ปิด (Mute)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            if (provider.buzzerActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🔔 BUZZER กำลังดัง!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForceStopButton(BuildContext context, GasProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.forceStopBuzzer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🔇 บังคับหยุด Buzzer + Mute แล้ว'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFF5722),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5722).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.stop_circle_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'หยุด Buzzer ทันที',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'บังคับหยุดเสียง + เปิด Mute',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, GasProvider provider) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('ยืนยันการรีเซ็ท'),
            content: const Text('คุณต้องการรีเซ็ท MQ2 Sensor หรือไม่?\nข้อมูลจะถูกรีเซ็ท'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  provider.resetSensor();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ รีเซ็ท MQ2 Sensor สำเร็จ!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('รีเซ็ท', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF44336).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.restart_alt_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'รีเซ็ท Sensor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'รีเซ็ท MQ2',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(GasProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ข้อมูลสถานะ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _statusRow(Icons.check_circle, 'ระบบ', 'กำลังทำงาน'),
          const SizedBox(height: 14),
          _statusRow(
            Icons.cloud_done,
            'เครือข่าย',
            provider.isConnected ? 'เชื่อมต่อแล้ว' : 'ตัดการเชื่อมต่อ',
          ),
          const SizedBox(height: 14),
          _statusRow(
            provider.buzzerActive ? Icons.notifications_active : Icons.notifications_off,
            'Buzzer',
            provider.buzzerActive ? 'กำลังดัง' : 'ปิด',
          ),
          const SizedBox(height: 14),
          _statusRow(
            provider.muteEnabled ? Icons.volume_off : Icons.volume_up,
            'Alert',
            provider.muteEnabled ? 'Mute' : 'เปิด',
          ),
        ],
      ),
    );
  }

  Widget _statusRow(IconData icon, String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}