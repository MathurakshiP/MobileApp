import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Introduction
              Text(
                'Introduction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This Privacy Policy explains how we handle your personal data collected through our mobile app.',
              ),
              SizedBox(height: 16),

              // Data Collection
              Text(
                'Data Collection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We collect personal information, usage data, and device information through forms, cookies, and third-party services.',
              ),
              SizedBox(height: 16),

              // Use of Data
              Text(
                'Use of Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The data we collect is used to improve our services, personalize user experience, and send notifications.',
              ),
              SizedBox(height: 16),

              // Data Sharing
              Text(
                'Data Sharing',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We may share your data with service providers, affiliates, and advertisers under certain conditions such as legal obligations or mergers.',
              ),
              SizedBox(height: 16),

              // Data Security
              Text(
                'Data Security',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We take measures to protect your data, but acknowledge that no system is 100% secure.',
              ),
              SizedBox(height: 16),

              // User Rights
              Text(
                'User Rights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You have the right to access, correct, and delete your data. Contact us or use account settings to exercise these rights.',
              ),
              SizedBox(height: 16),

              // Cookies and Tracking Technologies
              Text(
                'Cookies and Tracking Technologies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We use cookies and similar technologies for analytics and advertising purposes.',
              ),
              SizedBox(height: 16),

              // Third-Party Services
              Text(
                'Third-Party Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We use third-party services for analytics and payment processing, which handle user data according to their policies.',
              ),
              SizedBox(height: 16),

              // Data Retention
              Text(
                'Data Retention',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We retain your data for as long as necessary to provide our services and comply with legal obligations.',
              ),
              SizedBox(height: 16),

              // Changes to the Privacy Policy
              Text(
                'Changes to the Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We will notify you of any changes to this policy through app notifications or email. The changes will be effective from the date mentioned.',
              ),
              SizedBox(height: 16),

              // Contact Information
              Text(
                'Contact Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'For privacy-related concerns, contact us at support@example.com or call us at +1 234 567 890.',
              ),
              SizedBox(height: 16),

              // Children’s Privacy
              Text(
                'Children’s Privacy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our app is not intended for children under the age of 13. We do not knowingly collect data from children without parental consent.',
              ),
              SizedBox(height: 16),

              // Legal Basis for Processing Data
              Text(
                'Legal Basis for Processing Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We process your data based on consent, contractual necessity, and legal obligations.',
              ),
              SizedBox(height: 16),

              // International Data Transfers
              Text(
                'International Data Transfers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We may transfer your data across borders with appropriate safeguards in place.',
              ),
              SizedBox(height: 16),

              // User Consent
              Text(
                'User Consent',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'By using our app, you consent to this Privacy Policy. You can withdraw consent at any time through account settings.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
