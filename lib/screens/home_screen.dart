import 'package:flutter/material.dart';
import '../models/donasi_ini.dart';
import '../services/api_service.dart';
import 'edit_donasi_screen.dart';
import 'add_campaign_screen.dart'; // Pastikan Anda memiliki file ini

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Donasi>> futureDonasi;
  bool _isLoading = false;
  bool _showConnectionError = false;
  String _connectionErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _testApiConnection(); // Tambahkan test koneksi saat inisialisasi
  }

  // Method baru untuk test koneksi API
  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
      _showConnectionError = false;
    });

    try {
      // Uji koneksi API dengan ping.php
      bool isConnected = await ApiService.testConnection();
      
      if (isConnected) {
        print('API connection test successful');
        // Jika koneksi berhasil, lanjutkan dengan refresh data
        _refreshDonasi();
      } else {
        print('API connection test failed');
        
        // Coba dengan URL alternatif
        try {
          final altResponse = await ApiService.testDirectApi();
          if (altResponse) {
            print('Alternative API test successful');
            _refreshDonasi();
          } else {
            setState(() {
              _showConnectionError = true;
              _connectionErrorMessage = 'Tidak dapat terhubung ke server API. Pastikan server berjalan dan jaringan tersedia.';
              _isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            _showConnectionError = true;
            _connectionErrorMessage = 'Tidak dapat terhubung ke server API: $e';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error during API connection test: $e');
      setState(() {
        _showConnectionError = true;
        _connectionErrorMessage = 'Error saat menguji koneksi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDonasi() async {
    setState(() {
      _isLoading = true;
      futureDonasi = ApiService.getDonasi();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantoo'),
        actions: [
          // Tambahkan tombol refresh di AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testApiConnection, // Panggil test koneksi saat refresh
          ),
        ],
      ),
      body: _showConnectionError
          ? _buildConnectionErrorWidget() // Tampilkan widget error jika koneksi gagal
          : RefreshIndicator(
              onRefresh: _refreshDonasi,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Donasi>>(
                      future: futureDonasi,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final donasiList = snapshot.data ?? [];
                        if (donasiList.isEmpty) {
                          return const Center(child: Text('Belum ada data donasi'));
                        }

                        return ListView.builder(
                          itemCount: donasiList.length,
                          itemBuilder: (context, index) {
                            return DonasiCard(
                              donasi: donasiList[index],
                              onRefresh: _refreshDonasi,
                            );
                          },
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Tambahkan navigasi ke halaman tambah donasi
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCampaignScreen(),
            ),
          );
          
          // Refresh data jika berhasil menambahkan donasi baru
          if (result == true) {
            _refreshDonasi();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget baru untuk menampilkan pesan error koneksi
  Widget _buildConnectionErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Koneksi Gagal',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _connectionErrorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testApiConnection,
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Bantuan Koneksi'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Pastikan:'),
                          SizedBox(height: 8),
                          Text('1. Server XAMPP berjalan (Apache & MySQL)'),
                          Text('2. API tersedia di path yang benar'),
                          Text('3. Firewall tidak memblokir koneksi'),
                          Text('4. Emulator/device terhubung ke jaringan'),
                          SizedBox(height: 16),
                          Text('Detail teknis:'),
                          Text('• URL API: http://10.0.2.2/bantoo_api'),
                          Text('• Emulator menggunakan 10.0.2.2 untuk localhost'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Bantuan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DonasiCard extends StatefulWidget {
  final Donasi donasi;
  final VoidCallback onRefresh;

  const DonasiCard({
    super.key,
    required this.donasi,
    required this.onRefresh,
  });

  @override
  State<DonasiCard> createState() => _DonasiCardState();
}

class _DonasiCardState extends State<DonasiCard> {
  bool _isDeleting = false;

  Future<void> _deleteDonasi(int id) async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await ApiService.deleteDonasi(id);
      
      if (mounted) { // Periksa apakah widget masih ada
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donasi berhasil dihapus')),
          );
          widget.onRefresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus donasi')),
          );
        }
      }
    } catch (e) {
      if (mounted) { // Periksa apakah widget masih ada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image
          widget.donasi.foto != null && widget.donasi.foto!.isNotEmpty
              ? Image.network(
                  widget.donasi.foto!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image)),
                  ),
                )
              : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image)),
                ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.donasi.title ?? widget.donasi.nama ?? 'No Name', // Tambahkan fallback ke title jika ada
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.donasi.description != null && widget.donasi.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.donasi.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target: Rp ${widget.donasi.target?.toStringAsFixed(0) ?? widget.donasi.targetAmount?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Terkumpul: Rp ${widget.donasi.current?.toStringAsFixed(0) ?? widget.donasi.collectedAmount?.toStringAsFixed(0) ?? '0'}',
                          ),
                        ],
                      ),
                    ),
                    if (widget.donasi.isEmergency == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Darurat',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: widget.donasi.progress ?? 
                             (widget.donasi.target != null && widget.donasi.target! > 0 ? 
                             (widget.donasi.current ?? 0) / widget.donasi.target! : 0),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${((widget.donasi.progress ?? 
                         (widget.donasi.target != null && widget.donasi.target! > 0 ? 
                         (widget.donasi.current ?? 0) / widget.donasi.target! : 0)) * 100).toStringAsFixed(0)}% Complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isDeleting
                          ? null
                          : () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditDonasiScreen(
                                    donasi: widget.donasi,
                                  ),
                                ),
                              );
                              
                              if (result == true) {
                                widget.onRefresh();
                              }
                            },
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isDeleting
                          ? null
                          : () => _showDeleteConfirmation(context),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Hapus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus donasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDonasi(widget.donasi.id ?? 0);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}