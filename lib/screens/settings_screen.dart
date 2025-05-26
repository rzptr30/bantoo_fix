import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serverUrlController;
  bool _isTesting = false;
  String _testResult = '';
  bool _testSuccess = false;
  bool _isTestingDatabase = false;
  String _dbTestResult = '';
  bool _dbTestSuccess = false;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController(text: ApiService.baseUrl);
    _loadStoredUrl();
  }

  Future<void> _loadStoredUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUrl = prefs.getString('api_base_url') ?? ApiService.DEFAULT_URL;
      if (mounted) {
        setState(() {
          _serverUrlController.text = storedUrl;
        });
      }
    } catch (e) {
      print('Error loading stored URL: $e');
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isTesting = true;
      _testResult = 'Menguji koneksi ke server...';
      _testSuccess = false;
    });
    
    final testUrl = _serverUrlController.text.trim();
    
    try {
      final success = await ApiService.tryConnectToServer(testUrl);
      
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = success;
          _testResult = success 
              ? 'Koneksi ke server berhasil!' 
              : 'Gagal terhubung ke server. Periksa URL atau status server.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testResult = 'Error: $e';
        });
      }
    }
  }

  Future<void> _testDatabaseConnection() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Update the URL first
    final newUrl = _serverUrlController.text.trim();
    await ApiService.updateBaseUrl(newUrl);
    
    setState(() {
      _isTestingDatabase = true;
      _dbTestResult = 'Menguji koneksi ke database...';
      _dbTestSuccess = false;
    });
    
    try {
      final success = await ApiService.testDatabaseConnection();
      
      if (mounted) {
        setState(() {
          _isTestingDatabase = false;
          _dbTestSuccess = success;
          _dbTestResult = success 
              ? 'Koneksi ke database berhasil!' 
              : 'Gagal terhubung ke database. Periksa konfigurasi database di server.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTestingDatabase = false;
          _dbTestSuccess = false;
          _dbTestResult = 'Error: $e';
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newUrl = _serverUrlController.text.trim();
    await ApiService.updateBaseUrl(newUrl);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan server berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _serverUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Server API',
                    hintText: 'http://example.com/bantoo_api',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL tidak boleh kosong';
                    }
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return 'URL harus diawali dengan http:// atau https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_testResult.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testSuccess ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _testSuccess ? Colors.green : Colors.red),
                    ),
                    child: Text(
                      _testResult,
                      style: TextStyle(
                        color: _testSuccess ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_dbTestResult.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _dbTestSuccess ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _dbTestSuccess ? Colors.green : Colors.red),
                    ),
                    child: Text(
                      _dbTestResult,
                      style: TextStyle(
                        color: _dbTestSuccess ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isTesting ? null : _testConnection,
                        child: _isTesting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Uji Koneksi Server'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isTestingDatabase ? null : _testDatabaseConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: _isTestingDatabase
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Uji Koneksi Database'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan Pengaturan'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tips Pengaturan Server:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Untuk emulator Android, gunakan: http://10.0.2.2/bantoo_api'),
                const Text('• Untuk perangkat fisik, gunakan IP server yang benar, contoh: http://192.168.1.50/bantoo_api'),
                const Text('• Pastikan server dan bantoo_api tersedia di alamat tersebut'),
                const SizedBox(height: 16),
                const Text(
                  'Server Alternatif:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildAlternativeServerButton('http://10.0.2.2/bantoo_api', 'Android Emulator (10.0.2.2)'),
                const SizedBox(height: 8),
                _buildAlternativeServerButton('http://192.168.1.50/bantoo_api', 'Jaringan Lokal (192.168.1.50)'),
                const SizedBox(height: 8),
                _buildAlternativeServerButton('http://localhost/bantoo_api', 'Localhost'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeServerButton(String url, String label) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _serverUrlController.text = url;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.blue.shade300),
      ),
      child: Text('Gunakan $label'),
    );
  }
}