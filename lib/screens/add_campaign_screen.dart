import 'package:flutter/material.dart';
import '../models/donasi_ini.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';

class AddCampaignScreen extends StatefulWidget {
  final Donasi? existingDonasi;

  const AddCampaignScreen({super.key, this.existingDonasi});

  @override
  State<AddCampaignScreen> createState() => _AddCampaignScreenState();
}

class _AddCampaignScreenState extends State<AddCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  late TextEditingController _imageUrlController;
  bool _isEmergency = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingDonasi?.title ?? ''
    );
    _descriptionController = TextEditingController(
      text: widget.existingDonasi?.description ?? ''
    );
    _targetAmountController = TextEditingController(
      text: (widget.existingDonasi?.targetAmount ?? widget.existingDonasi?.target ?? '')
          .toString()
          .replaceAll('null', '')
    );
    _imageUrlController = TextEditingController(
      text: widget.existingDonasi?.imageUrl ?? widget.existingDonasi?.foto ?? ''
    );
    _isEmergency = widget.existingDonasi?.isEmergency ?? false;
    
    // Check server connection when screen initializes
    _checkServerConnection();
  }
  
  Future<void> _checkServerConnection() async {
    bool isConnected = await ApiService.testConnection();
    if (!isConnected && mounted) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi jaringan Anda atau status server.';
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // First check connectivity
    bool isConnected = await ApiService.testConnection();
    if (!isConnected && mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi jaringan Anda atau status server.';
      });
      return;
    }
    
    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final targetAmount = double.tryParse(_targetAmountController.text.replaceAll(',', '')) ?? 0.0;
      final imageUrl = _imageUrlController.text.trim();
      
      // Validate target amount to prevent large number issues
      if (targetAmount > 1000000000000) { // 1 trillion limit
        setState(() {
          _isLoading = false;
          _errorMessage = 'Jumlah target terlalu besar. Maksimal 1 triliun.';
        });
        return;
      }
      
      print('Saving campaign with title: $title');
      print('Target amount: $targetAmount');
      print('Is emergency: $_isEmergency');
      
      bool success;
      
      if (widget.existingDonasi != null) {
        // Mode edit
        print('Updating existing campaign with ID: ${widget.existingDonasi!.id}');
        success = await ApiService.updateDonasi(
          id: widget.existingDonasi!.id!,
          title: title,
          description: description,
          targetAmount: targetAmount,
          imageUrl: imageUrl,
          isEmergency: _isEmergency,
          collectedAmount: widget.existingDonasi!.collectedAmount ?? 0.0,
        );
      } else {
        // Mode tambah baru
        print('Creating new campaign');
        success = await ApiService.tambahDonasi(
          title: title,
          description: description,
          targetAmount: targetAmount,
          imageUrl: imageUrl,
          isEmergency: _isEmergency,
          collectedAmount: 0.0,
          deadline: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
      }
      
      print('API call result: $success');
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingDonasi != null 
            ? 'Campaign berhasil diperbarui' 
            : 'Campaign berhasil ditambahkan')),
        );
        Navigator.pop(context, true); // true menandakan sukses
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menyimpan campaign. Coba periksa koneksi atau coba lagi nanti.';
        });
      }
    } catch (e) {
      print('Error in _saveCampaign: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
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
        title: Text(widget.existingDonasi != null ? 'Edit Campaign' : 'Tambah Campaign'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (mounted) {
                setState(() {
                  _errorMessage = ''; // Clear error message after settings
                });
                _checkServerConnection(); // Check again after returning from settings
              }
            },
            tooltip: 'Pengaturan Server',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menyimpan data...'),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = '';
                                });
                                
                                // Test connection and update UI
                                bool isConnected = await ApiService.testConnection();
                                
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    if (!isConnected) {
                                      _errorMessage = 'Masih tidak dapat terhubung ke server. Periksa pengaturan server.';
                                    }
                                  });
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade900,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                ).then((_) {
                                  if (mounted) {
                                    _checkServerConnection();
                                  }
                                });
                              },
                              child: const Text('Buka Pengaturan Server'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Campaign',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Target Donasi',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Target donasi tidak boleh kosong';
                        }
                        final parsedValue = double.tryParse(value.replaceAll(',', ''));
                        if (parsedValue == null) {
                          return 'Target donasi harus berupa angka';
                        }
                        if (parsedValue <= 0) {
                          return 'Target donasi harus lebih besar dari 0';
                        }
                        if (parsedValue > 1000000000000) {
                          return 'Target donasi terlalu besar (max 1 triliun)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Link Gambar',
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/image.jpg',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Link gambar tidak boleh kosong';
                        }
                        if (!value.startsWith('http')) {
                          return 'Link gambar harus dimulai dengan http:// atau https://';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Kampanye Darurat'),
                      subtitle: const Text('Tandai sebagai kampanye darurat/mendesak'),
                      value: _isEmergency,
                      onChanged: (bool value) {
                        setState(() {
                          _isEmergency = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _errorMessage.isEmpty ? _saveCampaign : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        widget.existingDonasi != null ? 'Update Campaign' : 'Simpan Campaign',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}