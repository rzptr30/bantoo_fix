import 'package:flutter/material.dart';
import '../models/donasi_ini.dart';
import '../services/api_service.dart';

class EditDonasiScreen extends StatefulWidget {
  final Donasi donasi;

  const EditDonasiScreen({
    super.key,
    required this.donasi,
  });

  @override
  State<EditDonasiScreen> createState() => _EditDonasiScreenState();
}

class _EditDonasiScreenState extends State<EditDonasiScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nominalController;
  late TextEditingController _pesanController;
  late TextEditingController _fotoController;
  bool _isLoading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.donasi.nama ?? '');
    _nominalController = TextEditingController(text: widget.donasi.nominal?.toString() ?? '');
    _pesanController = TextEditingController(text: widget.donasi.pesan ?? '');
    _fotoController = TextEditingController(text: widget.donasi.foto ?? '');
    _progress = widget.donasi.progress ?? 0.0;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    _pesanController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _updateDonasi() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Pastikan untuk menyediakan ID yang valid
        final donasiId = widget.donasi.id;
        
        if (donasiId == null) {
          // Tangani kasus ketika ID tidak tersedia
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID donasi tidak valid')),
            );
          }
          return;
        }
        
        final success = await ApiService.updateDonasi(
          id: donasiId,  // Gunakan id yang valid
          nama: _namaController.text,
          nominal: double.tryParse(_nominalController.text),
          pesan: _pesanController.text,
          foto: _fotoController.text,
          progress: _progress,
        );
        
        if (mounted) { // Periksa apakah widget masih ada
          setState(() {
            _isLoading = false;
          });
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Donasi berhasil diperbarui')),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal memperbarui donasi')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donasi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nominalController,
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Nominal harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pesanController,
                      decoration: const InputDecoration(
                        labelText: 'Pesan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fotoController,
                      decoration: const InputDecoration(
                        labelText: 'URL Foto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Progress: ${(_progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _progress,
                      onChanged: (value) {
                        setState(() {
                          _progress = value;
                        });
                      },
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: '${(_progress * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateDonasi,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}