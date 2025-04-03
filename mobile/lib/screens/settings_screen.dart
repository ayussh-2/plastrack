import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../utils/preferences_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _frontendUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final serverUrl = await PreferencesUtils.getServerUrl();
    final frontendUrl = await PreferencesUtils.getFrontendUrl();

    _serverUrlController.text = serverUrl;
    _frontendUrlController.text = frontendUrl;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      developer.log(
        'Saving settings: Server URL: ${_serverUrlController.text}, Frontend URL: ${_frontendUrlController.text}',
        name: 'SettingsScreen',
      );

      final newServerUrl = _serverUrlController.text.trim();
      final newFrontendUrl = _frontendUrlController.text.trim();

      await PreferencesUtils.setServerUrl(newServerUrl);
      await PreferencesUtils.setFrontendUrl(newFrontendUrl);

      Constants.baseUrl = newServerUrl;
      Constants.frontendUrl = newFrontendUrl;
      Constants.ogImageEndpoint = '$newFrontendUrl/api/og-image';

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  Future<void> _testServerConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
      _testSuccess = false;
    });

    try {
      final urlString = _serverUrlController.text.trim().replaceAll('/api', '');
      if (urlString.isEmpty) {
        setState(() {
          _testSuccess = false;
          _testResult = 'Please enter a valid server URL.';
        });
        return;
      }

      developer.log(
        'Testing server connection: $urlString',
        name: 'SettingsScreen',
      );

      final url = Uri.parse(urlString);

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Connection timed out', 408),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _testSuccess = true;
          _testResult =
              'Connection successful! (Status: ${response.statusCode})';
        });
      } else {
        setState(() {
          _testSuccess = false;
          _testResult = 'Connection failed. Status: ${response.statusCode}';
        });
      }
    } on FormatException catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Invalid URL format. Please check the URL.';
      });
      developer.log(
        'URL format error: ${e.toString()}',
        name: 'SettingsScreen',
      );
    } on http.ClientException catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Connection error: Server unreachable';
      });
      developer.log(
        'HTTP client error: ${e.toString()}',
        name: 'SettingsScreen',
      );
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Error: ${e.toString()}';
      });
      developer.log(
        'Connection test error: ${e.toString()}',
        name: 'SettingsScreen',
      );
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _frontendUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Server URL
                      const Text(
                        'API Server URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serverUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Server URL',
                          hintText: 'http://192.168.0.104:4000/api',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter server URL';
                          }

                          // Basic URL validation
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isTesting ? null : _testServerConnection,
                              icon:
                                  _isTesting
                                      ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.network_check),
                              label: const Text('Test Connection'),
                            ),
                          ),
                        ],
                      ),
                      if (_testResult != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                _testSuccess
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _testSuccess ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              color:
                                  _testSuccess
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Frontend URL
                      const Text(
                        'Frontend URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _frontendUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Frontend URL',
                          hintText: 'http://192.168.0.100:3000',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter frontend URL';
                          }

                          // Basic URL validation
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save Settings'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
