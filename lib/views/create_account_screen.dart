import 'package:flutter/material.dart';
import 'package:dashboard_screen/utility/app_constants.dart';
import 'services/auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  String? _farmType;

  final List<String> _types = const [
    'Crop Farming',
    'Mixed Farming',
    'Horticulture',
    'Livestock',
    'Organic Farming',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _handleCreateAccount() async {
  if (!_formKey.currentState!.validate()) return;

  if (_farmType == null) {
    _showMessage('Please select farm type.');
    return;
  }

  setState(() => _isLoading = true);

  try {
    final success = await _authService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      farmType: _farmType!,
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _showMessage('Account created successfully. Please sign in.');

      Navigator.pop(context);
    } else {
      _showMessage('Registration failed. Try different email or check server.');
    }
  } catch (e) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    _showMessage('Network error. Please try again.');
    debugPrint("Register Error: $e");
  }
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.08)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppConstants.primaryGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.08)),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _isObscure,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Password is required';
          }
          if (value.trim().length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.primaryGreen),
          suffixIcon: IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppConstants.primaryGreen.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _farmType,
          hint: const Text('Farm Type'),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppConstants.primaryGreen),
          items: _types.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _farmType = newValue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png.png',
                  height: 130,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.agriculture, size: 64, color: AppConstants.primaryGreen);
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Join our community of farmers',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 25),
                _buildInputField(
                  icon: Icons.person_outline,
                  hint: 'Full Name',
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  icon: Icons.email_outlined,
                  hint: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email is required';
                    if (!text.contains('@')) return 'Enter valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  icon: Icons.phone_outlined,
                  hint: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  icon: Icons.location_on_outlined,
                  hint: 'Location / Village',
                  controller: _locationController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 15),
                _buildDropdownField(),
                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create My Account',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: AppConstants.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}