import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dashboard_screen/utility/app_constants.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
  static const _storage = FlutterSecureStorage();
  bool _isPremium = false;
  String _selectedMethod = 'JazzCash Demo';

  final List<String> _methods = const [
    'JazzCash Demo',
    'EasyPaisa Demo',
    'Bank Transfer Demo',
    'Card Payment Demo',
  ];

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final value = await _storage.read(key: 'subscription_status');
    if (!mounted) return;
    setState(() => _isPremium = value == 'premium');
  }

  Future<void> _activatePremium() async {
    await _storage.write(key: 'subscription_status', value: 'premium');
    await _storage.write(key: 'payment_method', value: _selectedMethod);
    if (!mounted) return;
    setState(() => _isPremium = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium plan activated for FYP demo.')),
    );
  }

  Future<void> _resetDemoPlan() async {
    await _storage.delete(key: 'subscription_status');
    await _storage.delete(key: 'payment_method');
    if (!mounted) return;
    setState(() => _isPremium = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium demo status reset.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgCream,
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusCard(),
            const SizedBox(height: 16),
            _planCard(
              title: 'Free Plan',
              price: 'Rs. 0',
              subtitle: 'Basic farmer support',
              icon: Icons.eco,
              features: const [
                'AI chatbot access',
                'Weather overview',
                'Government schemes',
                'Market rates',
              ],
              isHighlighted: false,
            ),
            const SizedBox(height: 16),
            _planCard(
              title: 'Premium Plan',
              price: 'Rs. 999 / month',
              subtitle: 'Advanced smart farming support',
              icon: Icons.workspace_premium,
              features: const [
                'Advanced AI crop guidance',
                'Priority weather alerts',
                'IoT monitoring dashboard',
                'Disease and irrigation risk insights',
                'Premium farmer support module',
              ],
              isHighlighted: true,
            ),
            const SizedBox(height: 18),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen),
            ),
            const SizedBox(height: 10),
            ..._methods.map((method) => _paymentMethodTile(method)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPremium ? null : _activatePremium,
                icon: Icon(_isPremium ? Icons.check_circle : Icons.lock_open),
                label: Text(_isPremium ? 'Premium Activated' : 'Activate Premium Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_isPremium) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetDemoPlan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Demo Subscription'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryGreen,
                    side: const BorderSide(color: AppConstants.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Note: This is a demo/sandbox payment module for final year project presentation. It does not process real money. In production, it can be connected with JazzCash, EasyPaisa, Stripe, or bank APIs.',
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isPremium ? AppConstants.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _isPremium ? Colors.white : AppConstants.lightGreen,
            child: Icon(_isPremium ? Icons.verified : Icons.lock_outline, color: AppConstants.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPremium ? 'Premium Farmer Account' : 'Free Farmer Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isPremium ? Colors.white : AppConstants.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPremium ? 'Advanced features are unlocked.' : 'Upgrade demo plan to show payment workflow.',
                  style: TextStyle(color: _isPremium ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String subtitle,
    required IconData icon,
    required List<String> features,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlighted ? AppConstants.primaryGreen : Colors.black12, width: isHighlighted ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isHighlighted ? AppConstants.primaryGreen : AppConstants.lightGreen,
                child: Icon(icon, color: isHighlighted ? Colors.white : AppConstants.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
                    Text(subtitle, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
            ],
          ),
          const SizedBox(height: 14),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppConstants.secondaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: const TextStyle(color: Colors.black87))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile(String method) {
    final selected = _selectedMethod == method;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppConstants.primaryGreen : Colors.black12),
      ),
      child: RadioListTile<String>(
        value: method,
        groupValue: _selectedMethod,
        activeColor: AppConstants.primaryGreen,
        title: Text(method, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Sandbox / academic demo'),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedMethod = value);
        },
      ),
    );
  }
}
