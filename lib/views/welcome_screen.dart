import 'package:flutter/material.dart';
import 'package:dashboard_screen/utility/app_constants.dart';

import 'create_account_screen.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryGreen,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/fields.bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.28)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.eco, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'FarmerChat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 43,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            children: [
                              TextSpan(
                                text: 'Smart\nFarming, ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Better\nDecisions',
                                style: TextStyle(color: AppConstants.goldenText),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'AI guidance · Market rates · Schemes · IoT monitoring',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppConstants.bgCream,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join farmers using AI support, live mandi rates, government schemes, and smart farm monitoring.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TagWidget(Icons.trending_up, 'Market Rates'),
                      SizedBox(width: 10),
                      TagWidget(Icons.account_balance, 'Schemes'),
                      SizedBox(width: 10),
                      TagWidget(Icons.smart_toy_outlined, 'AI Chat'),
                      SizedBox(width: 10),
                      TagWidget(Icons.sensors, 'IoT'),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryGreen,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppConstants.secondaryGreen,
                      width: 1.5,
                    ),
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'I Already Have an Account',
                    style: TextStyle(
                      color: AppConstants.secondaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TagWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  const TagWidget(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.goldenText, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}