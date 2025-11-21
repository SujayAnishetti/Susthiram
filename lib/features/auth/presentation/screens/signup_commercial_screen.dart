import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SignupCommercialScreen extends StatefulWidget {
  const SignupCommercialScreen({super.key});

  @override
  State<SignupCommercialScreen> createState() => _SignupCommercialScreenState();
}

class _SignupCommercialScreenState extends State<SignupCommercialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  final List<String> _orgTypes = ['Vendor', 'NGO', 'Company'];

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: Implement Firebase Auth & Role assignment
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/commercial-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212),
              Color(0xFF1A237E),
            ], // Deep Blue for Commercial
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner with us',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 40),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'For Vendors, NGOs, and Companies.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Organization Type',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: Colors.white70,
                      ),
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    items:
                        _orgTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => _selectedType = value),
                    validator:
                        (value) =>
                            value == null ? 'Please select a type' : null,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _orgNameController,
                    label: 'Organization Name',
                    icon: Icons.business,
                    delay: 400.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Business Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    delay: 500.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    delay: 600.ms,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF651FFF,
                        ), // Purple for Commercial
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Register Organization'),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: const Text('Already have an account? Login'),
                    ).animate().fadeIn(delay: 900.ms),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    required Duration delay,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2, end: 0);
  }
}
