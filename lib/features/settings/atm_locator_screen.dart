import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AtmLocatorScreen extends StatelessWidget {
  const AtmLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo ATM locations
    final List<Map<String, String>> atms = [
      {
        'name': 'Secure Bank Main Branch',
        'address': 'MotiJheel,Dhaka,Bangladesh',
        'status': 'Open 24/7',
        'distance': '0.5 miles',
      },
      {
        'name': 'Jamuna Future Park ATM',
        'address': 'Jamuna Future Park, Progoti Sharani, Dhaka, Bangladesh',
        'status': 'Open 24/7',
        'distance': '1.2 miles',
      },
      {
        'name': 'Bashundhara City Shopping Mall ATM',
        'address': 'Panthapath, Dhaka, Bangladesh',
        'status': 'Mall Hours',
        'distance': '2.8 miles',
      },
      {
        'name': 'Airport Terminal 2 ATM',
        'address':
            'Terminal 2, Hazrat Shahjalal International Airport, Dhaka, Bangladesh',
        'status': 'Open 24/7',
        'distance': '15.4 miles',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATM & Branch Locator'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Mock Map Area
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey[200],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Map view disabled for demo mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ATM List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: atms.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final atm = atms[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.atm, color: AppColors.primary),
                  ),
                  title: Text(
                    atm['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(atm['address']!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              atm['status']!,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            atm['distance']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.directions_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Directions feature is disabled in demo mode',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
