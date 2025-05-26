import 'package:flutter/material.dart';
import '../models/donasi_ini.dart';
import '../services/api_service.dart';
import 'edit_donasi_screen.dart';

class DonasiListScreen extends StatefulWidget {
  const DonasiListScreen({super.key});

  @override
  State<DonasiListScreen> createState() => _DonasiListScreenState();
}

class _DonasiListScreenState extends State<DonasiListScreen> {
  late Future<List<Donasi>> futureDonasi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshDonasi();
  }

  Future<void> _refreshDonasi() async {
    setState(() {
      futureDonasi = ApiService.getDonasi();
    });
  }

  Future<void> _deleteDonasi(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ApiService.deleteDonasi(id);
      
      if (mounted) { // Periksa apakah widget masih ada
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donasi berhasil dihapus')),
          );
          _refreshDonasi();
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Donasi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDonasi,
              child: FutureBuilder<List<Donasi>>(
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
                      final donasi = donasiList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15, 
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: donasi.foto != null && donasi.foto!.isNotEmpty
                              ? Image.network(donasi.foto!, width: 50, height: 50, fit: BoxFit.cover)
                              : const CircleAvatar(child: Icon(Icons.image)),
                          title: Text(donasi.nama ?? 'No Name'),
                          subtitle: Text(
                              'Nominal: Rp ${donasi.nominal?.toStringAsFixed(0) ?? '0'} - Pesan: ${donasi.pesan ?? '-'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditDonasiScreen(donasi: donasi),
                                    ),
                                  );
                                  
                                  if (result == true) {
                                    _refreshDonasi();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteConfirmation(context, donasi.id ?? 0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add donasi screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
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
              _deleteDonasi(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}