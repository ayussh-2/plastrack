import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';
import '../widgets/commons/text_field.dart';
import '../widgets/commons/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();

    // Populate controllers after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _populateUserData() {
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _cityController.text = user.city;
      _stateController.text = user.state;
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _populateUserData(); // Reset form data if canceling edit
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
        );

        if (success) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to update profile';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor1, AppTheme.backgroundColor2],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Your Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      _isEditing
                          ? TextButton(
                            onPressed: _toggleEditing,
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                          : IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: _toggleEditing,
                          ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // User avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User email (cannot be edited)
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Form for profile fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _isEditing
                            ? CustomTextField(
                              label: 'Full Name',
                              controller: _nameController,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            )
                            : _buildInfoRow(
                              'Name',
                              user.name,
                              Icons.person_outline,
                            ),

                        const SizedBox(height: 16),

                        _isEditing
                            ? CustomTextField(
                              label: 'Phone Number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                            )
                            : user.phone != null && user.phone!.isNotEmpty
                            ? _buildInfoRow(
                              'Phone',
                              user.phone!,
                              Icons.phone_outlined,
                            )
                            : _buildInfoRow(
                              'Phone',
                              'Not provided',
                              Icons.phone_outlined,
                            ),

                        const SizedBox(height: 16),

                        _isEditing
                            ? CustomTextField(
                              label: 'City',
                              controller: _cityController,
                              prefixIcon: Icon(
                                Icons.location_city_outlined,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your city';
                                }
                                return null;
                              },
                            )
                            : _buildInfoRow(
                              'City',
                              user.city,
                              Icons.location_city_outlined,
                            ),

                        const SizedBox(height: 16),

                        _isEditing
                            ? CustomTextField(
                              label: 'State',
                              controller: _stateController,
                              prefixIcon: Icon(
                                Icons.map_outlined,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your state';
                                }
                                return null;
                              },
                            )
                            : _buildInfoRow(
                              'State',
                              user.state,
                              Icons.map_outlined,
                            ),

                        const SizedBox(height: 30),

                        // Save button (only show when editing)
                        if (_isEditing)
                          PrimaryButton(
                            text: 'SAVE CHANGES',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _updateProfile,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
                ),
                SizedBox(height: 4.0),
                Text(
                  value,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
