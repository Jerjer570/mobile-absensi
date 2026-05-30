import 'package:flutter/material.dart';
import 'services/attendance_service.dart';

class PengajuanKoreksiAbsenPage extends StatefulWidget {
  const PengajuanKoreksiAbsenPage({super.key});

  @override
  State<PengajuanKoreksiAbsenPage> createState() => _PengajuanKoreksiAbsenPageState();
}

class _PengajuanKoreksiAbsenPageState extends State<PengajuanKoreksiAbsenPage> {
  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
  
  List<dynamic> daftarKoreksi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final result = await AttendanceService.getKoreksiHistory(status: selectedFilter);
    
    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          daftarKoreksi = result['data'];
          if (result['offline'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menampilkan data lokal (Offline)')),
            );
          }
        } else {
          daftarKoreksi = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      });
    }
  }

  Future<void> prosesHapus(int id) async {
    final result = await AttendanceService.deleteKoreksi(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['success']) {
        loadData();
      }
    }
  }

  IconData _getIcon(String jenis) {
    if (jenis.toLowerCase().contains('masuk')) return Icons.access_time;
    if (jenis.toLowerCase().contains('pulang')) return Icons.description_outlined;
    return Icons.calendar_today_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengajuan Koreksi Absen',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // --- TAB FILTER ---
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedFilter == filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedFilter = filters[index]);
                      loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- DAFTAR CARD ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : daftarKoreksi.isEmpty
                    ? const Center(child: Text('Tidak ada data koreksi absen.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: daftarKoreksi.length,
                        itemBuilder: (context, index) {
                          return _buildKoreksiCard(daftarKoreksi[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoreksiCard(Map<String, dynamic> data) {
    Color statusColor;
    Color statusBg;
    String statusStr = data['status'] ?? 'PENDING';
    bool isPending = statusStr == 'PENDING';

    if (statusStr == 'PENDING') {
      statusColor = const Color(0xFF854D0E);
      statusBg = const Color(0xFFFEF9C3);
    } else if (statusStr == 'DISETUJUI') {
      statusColor = const Color(0xFF166534);
      statusBg = const Color(0xFFDCFCE7);
    } else {
      statusColor = const Color(0xFF991B1B);
      statusBg = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getIcon(data['jenisKoreksi'] ?? ''), color: const Color(0xFF1E293B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['jenisKoreksi'] ?? 'Koreksi Absen', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(data['alasan'] ?? '-', 
                      style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      statusStr,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Koreksi'),
                            content: const Text('Batalkan pengajuan koreksi absen ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Kembali'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  prosesHapus(data['id']);
                                },
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          const Text('Tanggal', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(data['tanggal'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TERCATAT', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _timeRow('Masuk', data['checkInSistem'] ?? '--:--'),
                    const SizedBox(height: 4),
                    _timeRow('Keluar', data['checkOutSistem'] ?? '--:--'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DIAJUKAN', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _timeRow('Masuk', data['checkInUsulan'] ?? '--:--', isBold: true),
                    const SizedBox(height: 4),
                    _timeRow('Keluar', data['checkOutUsulan'] ?? '--:--', isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String time, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            time,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}