import 'package:flutter/material.dart';
import 'services/attendance_service.dart';

class PengajuanIzinPage extends StatefulWidget {
  const PengajuanIzinPage({super.key});

  @override
  State<PengajuanIzinPage> createState() => _PengajuanIzinPageState();
}

class _PengajuanIzinPageState extends State<PengajuanIzinPage> {
  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
  
  List<dynamic> daftarIzin = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    
    final result = await AttendanceService.getIzinHistory(status: selectedFilter);
    
    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          daftarIzin = result['data'];
          if (result['offline'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menampilkan data offline (Cache)')),
            );
          }
        } else {
          daftarIzin = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      });
    }
  }

  Future<void> prosesHapus(dynamic id) async {
    final result = await AttendanceService.deleteIzin(id);
    
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
    switch (jenis.toLowerCase()) {
      case 'izin-sakit': return Icons.medical_services_outlined;
      case 'izin-lainnya': return Icons.work_outline;
      case 'izin-cuti': return Icons.person_pin_circle_outlined;
      default: return Icons.person_outline;
    }
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
          'Pengajuan Izin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // --- FILTER TAB ---
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
                      setState(() {
                        selectedFilter = filters[index];
                      });
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

          // --- LIST PENGAJUAN ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : daftarIzin.isEmpty
                    ? const Center(child: Text('Tidak ada data pengajuan izin.'))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: daftarIzin.length,
                        itemBuilder: (context, index) {
                          final item = daftarIzin[index];
                          List<dynamic> tglList = item['tanggal'] ?? [];
                          String dateRange = tglList.isNotEmpty 
                              ? tglList.join(', ') 
                              : '-';

                          return _buildIzinCard(
                            id: item['id_pengajuanIzin'],
                            icon: _getIcon(item['jenis'] ?? ''),
                            title: item['jenis'] ?? '',
                            subtitle: item['alasan'] ?? '-',
                            status: item['status'] ?? 'PENDING',
                            date: dateRange,
                            duration: '${tglList.length} Hari',
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIzinCard({
    required dynamic id,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required String date,
    required String duration,
  }) {
    Color statusColor;
    Color statusBg;
    bool isPending = status == 'PENDING';

    if (status == 'PENDING') {
      statusColor = const Color(0xFF854D0E);
      statusBg = const Color(0xFFFEF9C3);
    } else if (status == 'DISETUJUI') {
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
                child: Icon(icon, color: const Color(0xFF1E293B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                      status,
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
                            title: const Text('Hapus Pengajuan'),
                            content: const Text('Apakah Anda yakin ingin menghapus pengajuan izin ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  prosesHapus(id);
                                },
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF1E293B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$date ($duration)', 
                  style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 11, 12, 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}